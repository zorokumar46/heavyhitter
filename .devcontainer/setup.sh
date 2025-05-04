#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

echo "🔥 Running OP Setup - Performance Mode ON..."

apt update && apt install -y python3-venv tlp unzip jq && apt clean && rm -rf /var/lib/apt/lists/*

echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
systemctl restart zramswap
systemctl start docker
systemctl enable tlp && systemctl start tlp

npm install -g npm yarn pm2

echo '* soft nofile 1048576' | tee -a /etc/security/limits.conf
echo '* hard nofile 1048576' | tee -a /etc/security/limits.conf
ulimit -n 1048576

cd "/workspaces/heavyhitter"

scripts=(
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/gh_installer.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/megen.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/mega.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/mega_downloader.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/ognode.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/pipe.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/gaiacloud.sh"
  "https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/restart_gaianet.sh"
)

echo "📥 Downloading all scripts..."

# Store filenames in an array
filenames=()

for url in "${scripts[@]}"; do
  filename=$(basename "$url")
  echo "⬇️ Downloading $filename..."
  curl -sSLO "$url"
  filenames+=("$filename")
done

echo "✅ All scripts downloaded!"

echo "🔓 Making downloaded scripts executable..."
for file in "${filenames[@]}"; do
  chmod +x "$file"
done

echo "🎉 All scripts are downloaded & ready! Run them manually when needed."

# install gh cli

echo "installing gh cli"

bash gh_installer.sh


echo "📝 Checking for MEGA_CREDENTIALS in Codespace secrets..."

if [[ -n "${MEGA_CREDENTIALS:-}" ]]; then
  echo "✅ MEGA_CREDENTIALS found! Making mega.env..."
  bash megen.sh
  echo "🎉 mega.env created successfully!"
else
  echo "⚠️ MEGA_CREDENTIALS not found! Skipping mega.env creation."
fi

# Function to check env & run script
run_if_env_exists() {
  local ENV_FILE="$1"
  local SCRIPT="$2"

  if [[ -f "$ENV_FILE" ]]; then
    echo "✅ $ENV_FILE found! Running $SCRIPT..."
    bash "$SCRIPT"
    echo "🎉 $SCRIPT completed with exit code $?"
  else
    echo "⚠️ $ENV_FILE not found! Skipping $SCRIPT..."
  fi
}

# List of env-script pairs
declare -a tasks=(
  "mega.env mega.sh"
  "mega.env mega_downloader.sh"
  "og.env ognode.sh"
  "pop.env pipe.sh"
)

# Loop through each task
for pair in "${tasks[@]}"; do
  read -r envfile script <<< "$pair"
  run_if_env_exists "$envfile" "$script"
done

# === New gaianet logic ===
TARGET_FILE="gaianet.7z"

echo "🔍 Checking if $TARGET_FILE exists in MEGA root..."
if mega-ls | grep -q "$TARGET_FILE"; then
  echo "✅ $TARGET_FILE exists on MEGA! Running gaiacloud.sh..."
  if bash ./gaiacloud.sh; then
    echo "🎉 gaiacloud.sh succeeded! Now running restart_gaianet.sh..."
    if bash ./restart_gaianet.sh; then
      echo "🚀 restart_gaianet.sh completed successfully!"
    else
      echo "❗ restart_gaianet.sh failed with exit code $?"
    fi
  else
    echo "❗ gaiacloud.sh failed with exit code $?. Skipping restart_gaianet.sh."
  fi
else
  # Silent exit if gaianet.7z not present
  exit 0
fi

echo "🎉 All downloaded scripts executed!"
# Check if Gbot.env exists in the current directory
if [ -f "Gbot.env" ]; then
    echo "✅ Gbot.env found! Running Gbot.sh script..."
    curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/Gbot.sh && bash Gbot.sh
else
    echo "⚠️ Gbot.env not found! Skipping Gbot.sh script..."
fi

#pull image for browser
docker pull  rohan014233/thorium

#run script for browser either restores it or makes new 
curl -sSLO https://raw.githubusercontent.com/naksh-07/Browser-Backup-Restore/refs/heads/main/restore.sh && bash restore.sh


# Stop containers from restarting automatically
for cid in $(docker ps -q); do
  docker update --restart=no "$cid"
done

# Stop all running Docker containers
echo "🛑 Stopping all running Docker containers..."
docker stop $(docker ps -q)

# Bonus thoda attitude mein
echo "💥 All containers stopped. Shanti mil gayi!"



# Start Codespace Tracker
cd /workspaces/heavyhitter/codespace-tracker
./setup.sh

echo "✅ All Done Bhai! Ultra OP Container READY 🚀"
