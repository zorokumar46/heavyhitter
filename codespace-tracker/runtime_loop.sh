#!/bin/bash
while true
do
    echo "🔁 Running runtime.py at $(date)" >> runtime.log
    python3 runtime.py >> runtime.log 2>&1
    sleep 63
done
