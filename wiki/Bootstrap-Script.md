# Bootstrap Script
The `bootstrap.sh` script is the primary driver for deploying the monitoring stack.

## Usage
```bash
bash bootstrap.sh
```

## Functionality
- Installs Docker and Docker Compose.
- Deploys the monitoring stack via `docker compose`.
- Provisions Grafana datasources and dashboards.
