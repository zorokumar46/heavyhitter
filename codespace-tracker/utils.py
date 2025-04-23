import os
import json
from datetime import datetime

def read_json(path):
    """
    Read data from a JSON file and return as a dictionary.
    If file does not exist or there is an error, returns an empty dict.
    """
    try:
        with open(path, "r") as file:
            return json.load(file)
    except Exception as e:
        print(f"❌ Error reading {path}: {e}")
        return {}

def write_json(path, data):
    """
    Write data to a JSON file.
    Pretty prints the data.
    """
    try:
        with open(path, "w") as file:
            json.dump(data, file, indent=4)
    except Exception as e:
        print(f"❌ Error writing to {path}: {e}")

def append_log(message, log_file=os.path.join(os.getcwd(), ".codespace-tracker", "debug.log")):
    """
    Append a log message to the debug log with a timestamp.
    """
    try:
        with open(log_file, "a") as log:
            log.write(f"[{datetime.now().isoformat()}] {message}\n")
    except Exception as e:
        print(f"❌ Error writing to log: {e}")

def get_current_datetime():
    """
    Return current date and time in ISO format (yyyy-mm-ddTHH:MM:SS).
    """
    return datetime.now().isoformat()

def format_minutes(minutes):
    """
    Format minutes as a readable string in hours and minutes.
    E.g., 125 minutes -> '2 hours 5 minutes'.
    """
    hours = minutes // 60
    minutes = minutes % 60
    return f"{hours} hours {minutes} minutes" if hours > 0 else f"{minutes} minutes"

def ensure_tracker_dir(path=".codespace-tracker"):
    """
    Ensures the runtime tracker directory exists.
    Creates it if it doesn't exist.
    """
    try:
        os.makedirs(path, exist_ok=True)
    except Exception as e:
        print(f"❌ Error creating directory {path}: {e}")
