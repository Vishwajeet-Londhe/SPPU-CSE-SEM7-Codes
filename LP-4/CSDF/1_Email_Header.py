import email
from email.parser import Parser
import re

# --- Sample email header ---
sample_header = """\
From: sender@example.com
To: receiver@example.com
Subject: Test Email
Date: Wed, 25 Sep 2025 10:30:00 +0530
Received: from mail.example.com (mail.example.com [192.168.1.10])
    by mx.google.com with ESMTP id abc123
    for <receiver@example.com>; Wed, 25 Sep 2025 10:30:00 +0530
Received: from smtp.example.org (smtp.example.org [203.0.113.5])
    by mail.example.com with ESMTP id xyz789
    for <receiver@example.com>; Wed, 25 Sep 2025 10:29:50 +0530
"""

# --- Parse header ---
parser = Parser()
msg = parser.parsestr(sample_header)

# --- Extract basic info ---
print("From:", msg['From'])
print("To:", msg['To'])
print("Subject:", msg['Subject'])
print("Date:", msg['Date'])

# --- Extract all Received headers (email path tracing) ---
received_headers = msg.get_all('Received', [])
print("\n--- Email Path (Received Headers) ---")
for i, header in enumerate(received_headers, start=1):
    print(f"Hop {i}: {header.strip()}")

# --- Extract IP addresses from Received headers ---
print("\n--- Extracted IP Addresses ---")
ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
for header in received_headers:
    ips = re.findall(ip_pattern, header)
    for ip in ips:
        print(ip)