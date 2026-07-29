#!/bin/bash
set -eu

# Script: bootstrap.sh
# Purpose: Orchestrates full monitoring stack deployment.

# Define directories
# Dynamically determine the repo root based on the script location
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/docs/scripts"

# Make scripts executable
chmod +x "$SCRIPTS_DIR"/*.sh

echo "Starting full monitoring stack bootstrap..."

# Detect OS
if [ -f /etc/debian_version ]; then
  OS="debian"
elif [ -f /etc/openwrt_release ]; then
  OS="openwrt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
else
  echo "Unsupported OS"
  exit 1
fi

echo "Detected OS: $OS"

# 1. Install Dependencies/Services based on OS
case $OS in
  debian)
    "$SCRIPTS_DIR/install-docker.sh"
    ;;
  openwrt)
    # OpenWrt specific bootstrap
    echo "Performing OpenWrt specific bootstrap..."
    ;;
  macos)
    # macOS specific bootstrap
    echo "Performing macOS specific bootstrap..."
    ;;
esac

# 2. Deploy Docker Compose Stack (Generic)
"$SCRIPTS_DIR/deploy-stack.sh"

# 3. Provision Grafana
"$SCRIPTS_DIR/setup-grafana.sh"

echo "Bootstrap complete."
