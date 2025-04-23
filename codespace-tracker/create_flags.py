import os

TRACKER_DIR = os.path.join(os.getcwd(), ".codespace-tracker")

os.makedirs(TRACKER_DIR, exist_ok=True)

flags = [
    "trigger_6min.flag",
    "trigger_20hrs.flag",
    "trigger_20hrs_180min.flag"
]

for flag in flags:
    path = os.path.join(TRACKER_DIR, flag)
    if not os.path.exists(path):
        with open(path, "w") as f:
            f.write("")
        print(f"✅ Created: {flag}")
    else:
        print(f"ℹ️ Already exists: {flag}")
