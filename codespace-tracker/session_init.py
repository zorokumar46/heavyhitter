import os
from datetime import datetime
import hashlib
from utils import read_json, write_json, ensure_tracker_dir, append_log

# Constants
TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")
FIRST_START_FILE = os.path.join(TRACKER_DIR, "first_start.json")
CURRENT_SESSION_FILE = os.path.join(TRACKER_DIR, "current_session.json")
MINUTE_RUNTIME_FILE = os.path.join(TRACKER_DIR, "minute_runtime.json")  # ✅ Added this

# Ensure directory exists
ensure_tracker_dir()

now = datetime.utcnow().isoformat()

# --- Session ID Generator ---
def generate_session_id(timestamp):
    session_hash = hashlib.sha256(timestamp.encode()).hexdigest()[:8]
    return f"{timestamp}_{session_hash}"

session_id = generate_session_id(now)

# --- Handle first_start.json ---
first_start_data = read_json(FIRST_START_FILE)

if not first_start_data or "start_time" not in first_start_data:
    print("🌟 Creating first_start.json for the first time...")
    first_start_data = {"start_time": now}
    write_json(FIRST_START_FILE, first_start_data)
    append_log("✅ first_start.json created.")
else:
    print("🕰️ first_start.json already exists with data.")

# --- Handle current_session.json ---
print("🔁 Initializing current_session.json...")
session_data = {
    "session_id": session_id,
    "start_time": now,
    "last_updated": now,
    "minutes": 0
}
write_json(CURRENT_SESSION_FILE, session_data)
append_log(f"✅ current_session.json initialized with session_id: {session_id}")

# --- ✅ Reset minute_runtime.json ---
write_json(MINUTE_RUNTIME_FILE, {"minutes": 0})
append_log("🔄 minute_runtime.json reset to 0.")
