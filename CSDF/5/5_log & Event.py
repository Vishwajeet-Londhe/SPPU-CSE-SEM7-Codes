import re
from collections import defaultdict

# --- Sample log file path ---
# Replace this with your actual log file path
log_file_path ="5_system.log"

# --- Keywords for event correlation ---
EVENT_KEYWORDS = {
    "ERROR": "Error",
    "WARNING": "Warning",
    "LOGIN_FAILED": "Failed Login",
    "LOGIN_SUCCESS": "Successful Login",
    "ACCESS_DENIED": "Access Denied"
}

# --- Read and capture logs ---
def read_logs(file_path):
    try:
        with open(file_path, 'r') as f:
            logs = f.readlines()
        return logs
    except FileNotFoundError:
        print(f"Log file {file_path} not found!")
        return []

# --- Analyze logs and correlate events ---
def analyze_logs(logs):
    event_summary = defaultdict(list)
    
    for line in logs:
        line = line.strip()
        for key, desc in EVENT_KEYWORDS.items():
            if key in line.upper():
                event_summary[desc].append(line)
    
    return event_summary

# --- Main ---
if __name__ == "__main__":
    logs = read_logs(log_file_path)
    
    if not logs:
        exit()

    events = analyze_logs(logs)

    print("\n--- Event Correlation Summary ---")
    for event_type, event_lines in events.items():
        print(f"\n{event_type} ({len(event_lines)} occurrences):")
        for l in event_lines:
            print(f"  {l}")
