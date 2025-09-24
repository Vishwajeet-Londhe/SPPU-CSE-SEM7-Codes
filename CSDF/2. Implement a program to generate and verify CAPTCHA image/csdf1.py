#!/usr/bin/env python3
"""
email_header_analyzer.py

Usage:
    python email_header_analyzer.py path/to/header.txt
or:
    cat header.txt | python email_header_analyzer.py

What it does:
- Parses a raw email header (RFC 5322 style).
- Extracts key fields: From, To, Subject, Message-ID, Date, Authentication-Results.
- Collects and parses all Received: headers, sorts hops by timestamp (best-effort).
- Extracts IP addresses from Received headers (and other headers).
- Optionally performs reverse DNS lookups (requires network).
- Prints a readable timeline of hops and a summary of likely origin IP(s).
- Gives investigation tips (SPF/DKIM/DMARC checks, geo-IP lookup suggestions).
"""

import sys
import re
import email
from email import policy
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
import socket
from collections import namedtuple

# Hop structure for parsed Received header info
ReceivedHop = namedtuple("ReceivedHop", ["raw", "from_part", "by_part", "with_part", "id_part", "for_part", "date", "ip_list"])

IP_REGEX = re.compile(r'\b(?:\d{1,3}\.){3}\d{1,3}\b')

def load_header_from_file_or_stdin(path=None):
    if path:
        with open(path, "rb") as f:
            raw = f.read()
    else:
        raw = sys.stdin.buffer.read()
    # Some files may contain full message; parse only headers up to first blank line
    # But email parser can parse full message and we'll only read headers.
    return raw

def parse_message(raw_bytes):
    return BytesParser(policy=policy.default).parsebytes(raw_bytes)

def extract_basic_fields(msg):
    fields = {
        "From": msg.get("From"),
        "To": msg.get("To"),
        "Subject": msg.get("Subject"),
        "Message-ID": msg.get("Message-ID"),
        "Date": msg.get("Date"),
        "Authentication-Results": msg.get("Authentication-Results")
    }
    return fields

def parse_received_header(raw_received):
    """
    Heuristic parse of a Received header into common clauses.
    We return a ReceivedHop. This is best-effort: Received headers vary a lot.
    """
    # Normalize whitespace
    s = " ".join(raw_received.split())
    # Extract date (after last ';')
    date = None
    if ";" in raw_received:
        try:
            # take text after last semicolon
            date_str = raw_received.rsplit(";", 1)[1].strip()
            date = parsedate_to_datetime(date_str)
        except Exception:
            date = None
    # Try to split "from ... by ... with ... id ... for ..."
    from_part = by_part = with_part = id_part = for_part = None
    # naive patterns
    m_from = re.search(r'\bfrom\s+(.+?)\s+(?=by\s|\Z)', s, re.IGNORECASE)
    if m_from:
        from_part = m_from.group(1).strip()
    m_by = re.search(r'\bby\s+(.+?)\s+(?=with\s|id\s|for\s|\Z)', s, re.IGNORECASE)
    if m_by:
        by_part = m_by.group(1).strip()
    m_with = re.search(r'\bwith\s+(.+?)\s+(?=id\s|for\s|\Z)', s, re.IGNORECASE)
    if m_with:
        with_part = m_with.group(1).strip()
    m_id = re.search(r'\bid\s+(.+?)\s+(?=for\s|\Z)', s, re.IGNORECASE)
    if m_id:
        id_part = m_id.group(1).strip()
    m_for = re.search(r'\bfor\s+(.+?)\s*(;|\Z)', s, re.IGNORECASE)
    if m_for:
        for_part = m_for.group(1).strip()
    # Extract IP addresses
    ip_list = IP_REGEX.findall(raw_received)
    # Filter out trivial private IPs if desired (we leave them; investigator can decide)
    return ReceivedHop(
        raw=raw_received,
        from_part=from_part,
        by_part=by_part,
        with_part=with_part,
        id_part=id_part,
        for_part=for_part,
        date=date,
        ip_list=ip_list
    )

def get_received_hops(msg):
    received_headers = msg.get_all("Received", [])
    hops = []
    for r in received_headers:
        hops.append(parse_received_header(r))
    return hops

def sort_hops_by_date(hops):
    # Some hops will have None date; keep their relative order but place undated at end.
    dated = [h for h in hops if h.date is not None]
    undated = [h for h in hops if h.date is None]
    dated_sorted = sorted(dated, key=lambda x: x.date)
    return dated_sorted + undated

def reverse_dns_lookup(ip):
    try:
        return socket.gethostbyaddr(ip)[0]
    except Exception:
        return None

def summarize_origin_ips(hops):
    # Heuristic: the earliest recorded public IP (in the last hop when sorted by date)
    # Also gather all distinct public-looking IPs.
    all_ips = []
    for h in hops:
        for ip in h.ip_list:
            all_ips.append(ip)
    # keep order and unique
    uniq = []
    for ip in all_ips:
        if ip not in uniq:
            uniq.append(ip)
    return uniq

def is_private_ip(ip):
    # Basic check for RFC1918 and some common private ranges
    private_prefixes = [
        ("10.",),
        ("172.", range(16, 32)),  # 172.16.0.0 - 172.31.255.255
        ("192.168.",)
    ]
    if ip.startswith("10."):
        return True
    if ip.startswith("192.168."):
        return True
    if ip.startswith("172."):
        second = int(ip.split(".")[1]) if len(ip.split(".")) > 1 and ip.split(".")[1].isdigit() else -1
        if 16 <= second <= 31:
            return True
    if ip.startswith("127.") or ip.startswith("169.254."):
        return True
    return False

def pretty_print_report(fields, hops_sorted, origin_ips):
    print("=== Email Header Analysis Report ===\n")
    print("Basic fields:")
    for k, v in fields.items():
        print(f"  {k}: {v}")
    print("\nAuthentication-Results:")
    print(f"  {fields.get('Authentication-Results')}\n")
    print("Received hops (oldest -> newest if dated):")
    for i, h in enumerate(hops_sorted, start=1):
        print(f"\nHop #{i}:")
        print(f"  Raw: {h.raw.strip()[:300]}{'...' if len(h.raw.strip())>300 else ''}")
        print(f"  from: {h.from_part}")
        print(f"  by:   {h.by_part}")
        print(f"  with: {h.with_part}")
        print(f"  id:   {h.id_part}")
        print(f"  for:  {h.for_part}")
        print(f"  date: {h.date}")
        if h.ip_list:
            print(f"  IPs found: {', '.join(h.ip_list)}")
            # mark private/public
            markers = []
            for ip in h.ip_list:
                markers.append(f"{ip} ({'private' if is_private_ip(ip) else 'public'})")
            print(f"  IP types: {', '.join(markers)}")
        else:
            print("  IPs found: none")
    print("\nSummary of IPs seen (in order encountered):")
    if origin_ips:
        for ip in origin_ips:
            note = "private" if is_private_ip(ip) else "public"
            rdns = None
            if not is_private_ip(ip):
                rdns = reverse_dns_lookup(ip)
            print(f"  {ip} - {note}{' - rDNS: ' + rdns if rdns else ''}")
    else:
        print("  No IPs detected in headers.")

    print("\nInvestigation tips / next steps:")
    print("  - Check 'Authentication-Results' for SPF / DKIM / DMARC results.")
    print("  - For each public IP, perform geo-IP lookup (e.g., ipinfo.io, MaxMind) and
    correlate with timestamps.")
    print("  - Perform reverse DNS (PTR) lookups to help identify sending hostnames.")
    print("  - Check Message-ID format — some forged messages have odd message-id domains.")
    print("  - If the earliest public IP is within an ISP/hosting provider, contact abuse@provider.")
    print("  - If hops show private IPs only, the message likely originated behind NAT — combine with other evidence.")
    print("  - Preserve the raw header and any related logs; document chain of custody.\n")
    print("Caveats:")
    print("  - Received headers are added by MTAs and can be forged; the earliest untrusted hop is typically the last Received added by the originating MTA you control.")
    print("  - Timestamps may be manipulated; rely on multiple indicators (Auth headers, PTR, MTA logs).\n")
    print("=== End of report ===")

def main(argv):
    path = argv[1] if len(argv) > 1 else None
    raw = load_header_from_file_or_stdin(path)
    msg = parse_message(raw)
    fields = extract_basic_fields(msg)
    hops = get_received_hops(msg)
    hops_sorted = sort_hops_by_date(hops)
    origin_ips = summarize_origin_ips(hops_sorted)
    pretty_print_report(fields, hops_sorted, origin_ips)

if __name__ == "__main__":
    main(sys.argv)
