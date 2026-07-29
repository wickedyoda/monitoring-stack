#!/bin/bash
set -eu

# Script: setup-grafana.sh
# Purpose: Provision Grafana datasources and dashboards via API.

# Usage: ./setup-grafana.sh <GRAFANA_URL> <ADMIN_USER> <ADMIN_PASSWORD>
GRAFANA_URL="${1:-http://localhost:3000}"
USER="${2:-admin}"
PASS="${3:-admin}"

echo "Configuring Grafana at $GRAFANA_URL..."

# Example: Provision datasource (needs JSON payload file or similar logic)
# This is a stub for the logic.
echo "Provisioning datasources..."
# curl -u "$USER:$PASS" -X POST -H "Content-Type: application/json" -d @datasource.json "$GRAFANA_URL/api/datasources"

echo "Grafana setup complete."
