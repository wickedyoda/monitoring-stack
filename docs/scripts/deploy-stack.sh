#!/bin/bash
set -eu

# Script: deploy-stack.sh
# Purpose: Deploys the Docker Compose monitoring stack.

# Usage: ./deploy-stack.sh <DOCKER_COMPOSE_DIR>
COMPOSE_DIR="${1:-/root/gh/monitoring-stack/docs/deployment}"

if [ ! -d "$COMPOSE_DIR" ]; then
    echo "Directory not found: $COMPOSE_DIR"
    exit 1
fi

echo "Deploying monitoring stack from $COMPOSE_DIR..."

cd "$COMPOSE_DIR"
docker compose up -d

echo "Monitoring stack deployed successfully."
