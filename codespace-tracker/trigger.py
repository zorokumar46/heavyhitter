import os
import json
import time
import subprocess
from datetime import datetime
from utils import read_json, append_log

TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
FLAG_DIR = os.path.join(TRACKER_DIR, "flags")
CONFIG_FILE = os.path.join(TRACKER_DIR, "trigger_config.json")

# Runtime files
MINUTE_RUNTIME_FILE = os.path.join(TRACKER_DIR, "minute_runtime.json")
TOTAL_RUNTIME_FILE = os.path.join(TRACKER_DIR, "total_runtime.json")
CURRENT_SESSION_FILE = os.path.join(TRACKER_DIR, "current_session.json")

# Make sure flags dir exists
os.makedirs(FLAG_DIR, exist_ok=True)

def run_script(url, command, cwd, flag_path, label):
    try:
        # Only download if script_url is provided and not empty
        if url and url.strip():
            subprocess.run(f"curl -sSLO {url}", shell=True, check=True, cwd=cwd)

        # Now run the command
        subprocess.run(command, shell=True, check=True, cwd=cwd)

        # Create a flag file to prevent repeat triggers
        with open(flag_path, "w") as f:
            f.write(datetime.utcnow().isoformat())

        append_log(f"✅ Triggered: {label}")
        print(f"🚀 {label} script executed!")

    except Exception as e:
        append_log(f"❌ Failed to run {label}: {e}")
        print(f"❌ Error: {label} script failed - {e}")

def conditions_met(conds, mins, hours, session_mins):
    return (
        conds.get("minute_runtime_minutes", 0) <= mins and
        conds.get("total_runtime_hours", 0) <= hours and
        conds.get("current_session_minutes", 0) <= session_mins
    )

def monitor_runtime():
    print("👀 Monitoring runtime using config...")
    while True:
        try:
            config = json.load(open(CONFIG_FILE))
            minute_data = read_json(MINUTE_RUNTIME_FILE)
            total_data = read_json(TOTAL_RUNTIME_FILE)
            session_data = read_json(CURRENT_SESSION_FILE)

            minutes = minute_data.get("minutes", 0)
            total_hours = total_data.get("total_hours", 0)
            session_minutes = session_data.get("minutes", 0)

            for item in config:
                flag_path = os.path.join(FLAG_DIR, item["flag_name"])
                if not os.path.exists(flag_path) and conditions_met(
                    item["conditions"], minutes, total_hours, session_minutes
                ):
                    run_script(
                        item.get("script_url", ""),  # default to empty string
                        item["script_command"],
                        item["cwd"],
                        flag_path,
                        item["label"]
                    )

            print(f"⏱️ Total: {total_hours}h | Session: {session_minutes}m | Minute: {minutes}m")

        except Exception as e:
            append_log(f"⚠️ Monitoring error: {e}")
            print(f"⚠️ Error: {e}")

        time.sleep(30)

def main():
    monitor_runtime()

if __name__ == "__main__":
    main()
