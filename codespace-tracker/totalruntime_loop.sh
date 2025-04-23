#!/bin/bash
while true
do
    echo "📊 Running totalruntime.py at $(date)" >> totalruntime.log
    python3 totalruntime.py >> totalruntime.log 2>&1
    sleep 67
done
