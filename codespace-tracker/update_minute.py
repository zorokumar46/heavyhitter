import os
import json
from datetime import datetime
from utils import read_json, write_json, ensure_tracker_dir

# Constants
TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
MINUTE_RUNTIME_FILE = os.path.join(TRACKER_DIR, "minute_runtime.json")
CURRENT_SESSION_FILE = os.path.join(TRACKER_DIR, "current_session.json")

# Ensure .codespace-tracker directory exists
ensure_tracker_dir(TRACKER_DIR)

# Load or initialize minute_runtime.json
minute_data = read_json(MINUTE_RUNTIME_FILE) or {"minutes": 0}
minute_data["minutes"] += 1
write_json(MINUTE_RUNTIME_FILE, minute_data)

# Load or initialize current_session.json
now = datetime.now().isoformat()
session_data = read_json(CURRENT_SESSION_FILE) or {
    "start_time": now,
    "last_updated": now,
    "minutes": 0
}

session_data["last_updated"] = now
session_data["minutes"] += 1
write_json(CURRENT_SESSION_FILE, session_data)

# Optional debug log
with open(os.path.join(TRACKER_DIR, "debug.log"), "a") as f:
    f.write(f"[{now}] Minute updated. Total: {minute_data['minutes']} mins | Session: {session_data['minutes']} mins\n")
