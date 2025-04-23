#!/bin/bash

# Define the target directory
TARGET_DIR="$PWD/.codespace-tracker/flags"

# Check if the directory exists
if [ -d "$TARGET_DIR" ]; then
  echo "Deleting contents of $TARGET_DIR..."
  rm -rf "$TARGET_DIR"/*
  echo "Done."
else
  echo "Directory $TARGET_DIR does not exist."
fi
