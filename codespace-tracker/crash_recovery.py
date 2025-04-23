import os
import json
from datetime import datetime

TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
CURRENT_SESSION_FILE = os.path.join(TRACKER_DIR, "current_session.json")
MINUTE_RUNTIME_FILE = os.path.join(TRACKER_DIR, "minute_runtime.json")
SESSION_LOGS_FILE = os.path.join(TRACKER_DIR, "session_logs.json")
DEBUG_LOG = os.path.join(TRACKER_DIR, "debug.log")

def read_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except:
        return {}

def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)

def append_log(message):
    with open(DEBUG_LOG, "a") as log:
        log.write(f"[{datetime.now().isoformat()}] {message}\n")

def recover_if_crashed():
    session = read_json(CURRENT_SESSION_FILE)
    minute_data = read_json(MINUTE_RUNTIME_FILE)
    logs = read_json(SESSION_LOGS_FILE)

    if not isinstance(logs, list):
        logs = []

    if session and minute_data:
        start_time = session.get("start_time")
        session_id = session.get("session_id")
        minutes = minute_data.get("minutes", 0)

        if start_time and session_id and minutes > 0:
            end_time = datetime.utcnow().isoformat()
            date = start_time.split("T")[0]

            # Check if an unrecovered log with this session_id exists
            existing_log = next(
                (log for log in logs if log.get("session_id") == session_id and not log.get("recovered", False)),
                None
            )

            if existing_log:
                # Update the existing log instead of adding new
                existing_log["end_time"] = end_time
                existing_log["duration_minutes"] = minutes
                existing_log["recovered"] = True
                append_log(f"🔁 Updated unrecovered session: {session_id} | Duration set to {minutes} mins")
                print("🔁 Crash recovery: Existing log updated.")
            else:
                # Append new recovery entry
                recovered_session = {
                    "session_id": session_id,
                    "start_time": start_time,
                    "end_time": end_time,
                    "duration_minutes": minutes,
                    "recovered": True,
                    "date": date
                }
                logs.append(recovered_session)
                append_log(f"🆕 Recovered session added: {session_id} | {minutes} mins from {start_time}")
                print("🆕 Crash recovery successful. New session log added.")

            # Save updated logs
            write_json(SESSION_LOGS_FILE, logs)

            append_log("✅ Session recovery complete. Now it's time to reset session and runtime in separate scripts.")

        else:
            append_log("✅ No recovery needed. Clean or incomplete session.")
    else:
        append_log("✅ No recovery needed. Files missing or empty.")

def main():
    recover_if_crashed()

if __name__ == "__main__":
    main()
