# Dashboard Provisioning (Manual)

This document describes how to automate the provisioning of Grafana dashboards using the Grafana API.

## Logic Overview
The `docs/scripts/provision-dashboard.sh` script utilizes the Grafana HTTP API to push a dashboard JSON definition directly into the instance.
1. **Targeting**: Requires a reachable Grafana instance URL and an API key with `Editor` or `Admin` privileges.
2. **Execution**: Uses `curl` to POST the JSON content to `/api/dashboards/db`.
3. **Outcome**: The dashboard is dynamically added to the Grafana instance without human interaction in the GUI.

## Operational Requirements
- **Dashboard JSON**: Must be valid JSON matching the format exported by Grafana.
- **API Access**: An API key (Service Account token) is required.

## Usage Example
```bash
./docs/scripts/provision-dashboard.sh "http://grafana.internal:3000" "eyJh...key" "dashboards/node-stats.json"
```

## Failure Modes & Debugging
- **"401 Unauthorized"**: The API token is invalid or expired.
- **"400 Bad Request"**: The JSON file provided is malformed or missing critical Grafana dashboard fields.
- **"Connection Failed"**: Check if the Grafana service is up and reachable from the execution host.

## The "Why": Programmatic Provisioning
Manual dashboard creation is brittle and hard to version control. By scripting the provisioning, we ensure that every deployment of the monitoring stack can recreate the same set of dashboards automatically, which is essential for CI/CD and disaster recovery.
