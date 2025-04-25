#!/bin/bash

# === Safe Flag Cleaner by Gyandu Bhai ===

TARGET_DIR="$PWD/.codespace-tracker/flags"
KEEP_FLAGS=("trigger_browserbackup.flag" "trigger_mega-uploader.flag")  # ⬅️ Add more flags here

if [[ -d "$TARGET_DIR" ]]; then
  echo "🧹 Cleaning flags (excluding important ones)..."
  
  for flag in "$TARGET_DIR"/*; do
    fname=$(basename "$flag")
    if [[ ! " ${KEEP_FLAGS[*]} " =~ " ${fname} " ]]; then
      echo "🗑️ Deleting: $fname"
      rm -f "$flag"
    else
      echo "🛡️ Keeping: $fname"
    fi
  done

  echo "✅ Flag cleanup done."
else
  echo "❌ Directory $TARGET_DIR does not exist."
fi
