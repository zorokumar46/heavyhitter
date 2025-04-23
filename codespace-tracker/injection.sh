#!/bin/bash

# Absolute path of codespace-tracker dir
TRACKER_PATH="$(pwd)"

START_TAG="# >>> Codespace Tracker Auto Start with Boot Detection <<<"
END_TAG="# <<< Codespace Tracker Auto Start with Boot Detection <<<"

AUTO_BLOCK=$(cat <<EOF
$START_TAG

cd "$TRACKER_PATH" || exit

CURRENT_BOOT_ID="\$(cat /proc/sys/kernel/random/boot_id)"
BOOT_ID_FILE="$TRACKER_PATH/.codespace-tracker/boot_id.txt"

# Boot-aware logic: only run once per Codespace boot
if [ ! -s "\$BOOT_ID_FILE" ]; then
    echo "🟢 boot_id.txt missing or empty. Assuming fresh boot."
    echo "\$CURRENT_BOOT_ID" > "\$BOOT_ID_FILE"

    if [ -f "$TRACKER_PATH/chalu.sh" ]; then
        bash "$TRACKER_PATH/chalu.sh"
    fi

    (
        sleep 30
        if [ -f "$TRACKER_PATH/start_all.sh" ]; then
            bash "$TRACKER_PATH/start_all.sh" &
        fi
    ) &

elif [ "\$CURRENT_BOOT_ID" != "\$(cat \$BOOT_ID_FILE)" ]; then
    echo "🟢 New boot detected. Starting tracker..."
    echo "\$CURRENT_BOOT_ID" > "\$BOOT_ID_FILE"

    if [ -f "$TRACKER_PATH/chalu.sh" ]; then
        bash "$TRACKER_PATH/chalu.sh"
    fi

    (
        sleep 30
        if [ -f "$TRACKER_PATH/start_all.sh" ]; then
            bash "$TRACKER_PATH/start_all.sh" &
        fi
    ) &
else
    echo "🕓 Terminal opened. Tracker already initialized."
fi

$END_TAG
EOF
)

# Clean old block
sed -i "/$START_TAG/,/$END_TAG/d" ~/.bashrc

# Inject smart block
echo -e "\n$AUTO_BLOCK" >> ~/.bashrc
echo "✅ Smart Codespace Tracker boot-based block added to ~/.bashrc!"
