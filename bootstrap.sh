#!/bin/bash
set -eux

# 1. Host Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Unsupported OS"
    exit 1
fi

ARCH=$(uname -m)
echo "Detecting OS: $OS $VERSION, Arch: $ARCH"

# 2. Install Docker
case $OS in
  debian|ubuntu)
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
    ;;
  *)
    echo "Installation not automated for: $OS"
    exit 1
    ;;
esac

echo "Docker installed successfully."
