#!/bin/bash

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
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/mega.sh && bash mega.sh
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/mega_downloader.sh && bash mega_downloader.sh
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/ognode.sh && bash ognode.sh
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/pipe.sh && bash pipe.sh
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/gaiacloud.sh && bash gaiacloud.sh
curl -sSLO https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/restart_gaianet.sh && bash restart_gaianet.sh

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
