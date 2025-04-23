import os
import json
from datetime import datetime
from dateutil import parser

TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
CURRENT_SESSION_FILE = os.path.join(TRACKER_DIR, "current_session.json")
SESSION_LOGS_FILE = os.path.join(TRACKER_DIR, "session_logs.json")

def read_json(path):
    if os.path.exists(path):
        try:
            with open(path) as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error reading {path}: {e}")
    return {}

def write_json(path, data):
    try:
        with open(path, "w") as f:
            json.dump(data, f, indent=4)
    except Exception as e:
        print(f"❌ Error writing to {path}: {e}")

def calculate_duration_minutes(start, end):
    start_dt = parser.isoparse(start)
    end_dt = parser.isoparse(end)
    return int((end_dt - start_dt).total_seconds() // 60)

def update_session_logs():
    current_session = read_json(CURRENT_SESSION_FILE)
    logs = read_json(SESSION_LOGS_FILE)

    if "start_time" not in current_session or "session_id" not in current_session:
        print("❌ Missing session_id or start_time in current_session.json")
        return

    session_id = current_session["session_id"]
    start_time = current_session["start_time"]
    end_time = datetime.utcnow().isoformat()
    duration_minutes = calculate_duration_minutes(start_time, end_time)

    # Ensure logs is a list
    if not isinstance(logs, list):
        logs = []

    # Check if session_id already exists
    updated = False
    for entry in logs:
        if entry.get("session_id") == session_id and not entry.get("recovered", False):
            entry["end_time"] = end_time
            entry["duration_minutes"] = duration_minutes
            entry["date"] = datetime.utcnow().date().isoformat()
            updated = True
            break

    # If not found, append new entry
    if not updated:
        log_entry = {
            "session_id": session_id,
            "start_time": start_time,
            "end_time": end_time,
            "duration_minutes": duration_minutes,
            "recovered": False,
            "date": datetime.utcnow().date().isoformat()
        }
        logs.append(log_entry)
        print("🆕 New session entry added.")

    write_json(SESSION_LOGS_FILE, logs)
    print(f"✅ Session log updated: {duration_minutes} mins | ID: {session_id}")

def main():
    update_session_logs()

if __name__ == "__main__":
    main()
