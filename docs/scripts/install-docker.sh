#!/bin/bash
set -eu

# Script: install-docker.sh
# Purpose: Installs Docker and Docker Compose on Debian/Ubuntu systems.

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

OS=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
ARCH=$(uname -m)

echo "Installing Docker on $OS ($ARCH)..."

apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=\"$ARCH\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker installed successfully."
