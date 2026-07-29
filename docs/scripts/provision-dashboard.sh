#!/bin/bash
set -eux
# Usage: ./provision-dashboard.sh <GRAFANA_URL> <API_TOKEN> <DASHBOARD_JSON_FILE>

GRAFANA_URL=${1:-"https://pine.tyates.one"}
TOKEN=${2:-""}
DASHBOARD_JSON=${3:-""}

if [ -z "$TOKEN" ] || [ -z "$DASHBOARD_JSON" ]; then
  echo "Usage: $0 <GRAFANA_URL> <API_TOKEN> <DASHBOARD_JSON_FILE>"
  exit 1
fi

curl -sS -X POST -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     --data @"$DASHBOARD_JSON" \
     "$GRAFANA_URL/api/dashboards/db"
