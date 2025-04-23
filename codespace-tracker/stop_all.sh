#!/bin/bash
echo "🛑 Stopping all Codespace Tracker scripts..."

# Kill all relevant Python & Bash scripts used in Codespace Tracker
pkill -f update_minute.py
pkill -f runtime.py
pkill -f totalruntime.py
pkill -f trigger.py
pkill -f ghadi.sh

echo "✅ All background scripts stopped!"
