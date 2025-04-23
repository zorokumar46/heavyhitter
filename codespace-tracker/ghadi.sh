#!/bin/bash

echo ""
echo "🕰️ Ghadi shuru ho gayi... Time tracking every minute!"

while true
do
    # Run the minute updater script
    python3 "$(pwd)/update_minute.py"

    # Wait for 60 seconds
    sleep 60
done
