#!/bin/bash
shopt -s nullglob

TARGET_DIR="$PWD/.codespace-tracker/flags"
KEEP_FLAGS=("trigger_browserbackup.flag" "trigger_mega-uploader.flag" "25hr_trigger_mega-uploader.flag" "25_hr_trigger_browserbackup.flag")

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ Directory $TARGET_DIR does not exist."
  exit 1
fi

echo "🧹 Cleaning flags (excluding important ones)..."
for flag in "$TARGET_DIR"/*; do
  fname=$(basename "$flag")
  keep=false
  for k in "${KEEP_FLAGS[@]}"; do
    [[ "$fname" == "$k" ]] && keep=true
  done

  if ! $keep; then
    echo "🗑️ Deleting: $fname"
    rm -f -- "$flag"
  else
    echo "🛡️ Keeping:  $fname"
  fi
done
shopt -u nullglob

echo "✅ Flag cleanup done."
