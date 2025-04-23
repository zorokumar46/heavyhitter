#!/bin/bash

echo ""
echo "🔧 Starting Codespace Tracker Setup..."

# 1. Create tracker directory if not exists
TRACKER_DIR=".codespace-tracker"
if [ ! -d "$TRACKER_DIR" ]; then
    echo "📁 Creating tracker directory: $TRACKER_DIR"
    mkdir -p "$TRACKER_DIR"
else
    echo "📁 Tracker directory already exists."
fi

# 2. Create JSON/log files
declare -a files=("current_session.json" "minute_runtime.json" "session_logs.json" "total_runtime.json" "debug.log" "boot_id.txt")
for file in "${files[@]}"
do
    path="$TRACKER_DIR/$file"
    if [ ! -f "$path" ]; then
        echo "📄 Creating $file"
        if [[ $file == *.json ]]; then
            echo "{}" > "$path"
        else
            touch "$path"
        fi
    else
        echo "✅ $file already exists."
    fi
done

# 3. Python Check
python3 --version >/dev/null 2>&1 || { echo "❌ Python3 not found!"; exit 1; }

# 4. pip Check
if ! command -v pip3 >/dev/null 2>&1; then
    echo "⚠️ pip3 not found. Attempting to install..."
    sudo apt update
    sudo apt install -y python3-pip || { echo "❌ Failed to install pip3!"; exit 1; }
    echo "✅ pip3 installed successfully."
else
    echo "✅ pip3 is already installed."
fi

# 5. Install Dependencies
echo "📦 Installing/upgrading dependencies from requirements.txt..."
pip3 install --upgrade -r requirements.txt

# 6. Boot ID logic (Self-aware Codespace!)
CURRENT_BOOT_ID=$(cat /proc/sys/kernel/random/boot_id)
BOOT_ID_FILE="$TRACKER_DIR/boot_id.txt"

if [ ! -s "$BOOT_ID_FILE" ]; then
    echo "🟢 boot_id.txt missing or empty. Assuming fresh boot."
    echo "$CURRENT_BOOT_ID" > "$BOOT_ID_FILE"
elif [ "$CURRENT_BOOT_ID" != "$(cat "$BOOT_ID_FILE")" ]; then
    echo "🟢 New boot detected during setup. Updating boot_id.txt..."
    echo "$CURRENT_BOOT_ID" > "$BOOT_ID_FILE"
else
    echo "🕓 Same boot detected. Skipping chalu/start_all."
fi

# 7. Initialize Session (if new boot)
if [ "$CURRENT_BOOT_ID" != "$(cat "$BOOT_ID_FILE")" ] || [ ! -s "$BOOT_ID_FILE" ]; then
    echo "🚀 Initializing new session via session_init.py..."
    python3 session_init.py

    echo "🧠 Starting all background trackers..."
    bash start_all.sh
else
    echo "🔁 Tracker already initialized this boot. Skipping start."
fi

# 8. Make loop scripts executable
chmod +x runtime_loop.sh totalruntime_loop.sh

# 9. Inject smart block into bashrc
bash injection.sh

echo ""
echo "✅ Codespace Tracker setup complete!"
