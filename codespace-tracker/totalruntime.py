import os
import json
from datetime import datetime
from dateutil import parser

TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
SESSION_LOGS_FILE = os.path.join(TRACKER_DIR, "session_logs.json")
TOTAL_RUNTIME_FILE = os.path.join(TRACKER_DIR, "total_runtime.json")

def read_json(path):
    if os.path.exists(path):
        try:
            with open(path) as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error reading {path}: {e}")
    return []

def write_json(path, data):
    try:
        with open(path, "w") as f:
            json.dump(data, f, indent=4)
        print(f"✅ Wrote to {path}")
    except Exception as e:
        print(f"❌ Error writing to {path}: {e}")

def get_now():
    return datetime.utcnow().isoformat()

def calculate_total_runtime():
    logs = read_json(SESSION_LOGS_FILE)

    if not isinstance(logs, list):
        print("⚠️ session_logs.json is not a list. Resetting to empty list.")
        logs = []

    valid_sessions = []
    total_minutes = 0

    # Calculate total runtime by summing valid session durations
    for session in logs:
        try:
            duration = session.get("duration_minutes")
            # Double-check if duration is valid
            if duration is None and "start_time" in session and "end_time" in session:
                start = parser.isoparse(session["start_time"])
                end = parser.isoparse(session["end_time"])
                duration = int((end - start).total_seconds() // 60)

            if duration:
                total_minutes += duration
                valid_sessions.append(session)
        except Exception as e:
            print(f"⚠️ Skipped one corrupted session: {e}")

    total_hours = round(total_minutes / 60, 2)

    # Prepare stats for updating total_runtime.json
    stats = {
        "total_minutes": total_minutes,
        "total_hours": total_hours,
        "session_count": len(valid_sessions),
        "last_updated": get_now()
    }

    # Update the total runtime JSON
    write_json(TOTAL_RUNTIME_FILE, stats)
    print(f"🔄 Total runtime updated: {total_minutes} minutes ({total_hours} hours) across {len(valid_sessions)} sessions.")

def main():
    calculate_total_runtime()

if __name__ == "__main__":
    main()
