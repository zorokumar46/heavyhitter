#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "🚀 Starting all services for Codespace Tracker..."

echo "⏰ Starting clock (ghadi.sh)..."
nohup bash "$SCRIPT_DIR/ghadi.sh" > ghadi.log 2>&1 &

echo "⏳ Starting runtime_loop.sh (every 20 minutes)..."
nohup bash "$SCRIPT_DIR/runtime_loop.sh" > runtime_loop.log 2>&1 &

echo "📊 Starting totalruntime_loop.sh (every 25 minutes)..."
nohup bash "$SCRIPT_DIR/totalruntime_loop.sh" > totalruntime_loop.log 2>&1 &

echo "🔁 Starting trigger.py (always running in background)..."
nohup python3 "$SCRIPT_DIR/trigger.py" > trigger.log 2>&1 &

echo "✅ All services are now running! Codespace tracker is active."
