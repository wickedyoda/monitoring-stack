#!/bin/bash
set -eu

# Script: bootstrap.sh
# Purpose: Orchestrates full monitoring stack deployment.

# Define directories
REPO_ROOT="/root/gh/monitoring-stack"
SCRIPTS_DIR="$REPO_ROOT/docs/scripts"

# Make scripts executable
chmod +x "$SCRIPTS_DIR"/*.sh

echo "Starting full monitoring stack bootstrap..."

# 1. Install Docker
"$SCRIPTS_DIR/install-docker.sh"

# 2. Deploy Docker Compose Stack
"$SCRIPTS_DIR/deploy-stack.sh"

# 3. Provision Grafana
"$SCRIPTS_DIR/setup-grafana.sh"

echo "Bootstrap complete."
