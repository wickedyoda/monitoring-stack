# Script Reference

This document provides a detailed breakdown of the automation scripts available in the monitoring-stack repository.

---

## 1. `bootstrap.sh`

### Purpose
Acts as the central orchestrator to deploy the monitoring stack, handling OS detection and invoking sub-scripts.

### Requirements
- Root/sudo access.
- Supported OS: Debian/Ubuntu, OpenWrt, or macOS.

### Operational Breakdown
1. Detects the host operating system (`/etc/debian_version`, `/etc/openwrt_release`, or `OSTYPE`).
2. Makes all scripts in `docs/scripts/` executable.
3. Based on the detected OS, runs the appropriate installation logic (e.g., installs Docker for Debian).
4. Invokes `deploy-stack.sh` and `setup-grafana.sh` to complete the deployment.

### Troubleshooting
- **Permission Denied:** Ensure you have root privileges.
- **Unsupported OS:** The script currently supports only Debian-based, OpenWrt, and macOS systems.

---

## 2. `docs/scripts/install-docker.sh`

### Purpose
Performs a clean installation of Docker and Docker Compose (plugin) on Debian-based systems.

### Requirements
- Debian or Ubuntu system.
- Root privileges.

### Operational Breakdown
1. Updates `apt` package lists and installs dependencies (`ca-certificates`, `curl`, `gnupg`).
2. Downloads and installs the Docker GPG key to `/etc/apt/keyrings/docker.gpg`.
3. Adds the Docker repository for the host's Debian version/codename.
4. Installs `docker-ce`, `docker-compose-plugin`, and related tools.

### Troubleshooting
- **Repository Missing:** Verify if your OS/distro version is officially supported by Docker.
- **Apt Lock:** If an `apt` lock file exists, wait for the background process to finish or restart the system.

---

## 3. `docs/scripts/install-telegraf.sh`

### Purpose
Installs and configures the Telegraf agent for metrics collection.

### Requirements
- Host OS: Debian, OpenWrt, or macOS.
- An InfluxDB API token.

### Operational Breakdown
1. Detects the package manager (`apt-get`, `opkg`, or `brew`).
2. Installs Telegraf based on the package manager.
3. Creates a secure environment file (e.g., `/etc/telegraf/secrets/influxdb_env`) to store the provided InfluxDB token.
4. Enables and restarts the Telegraf service.

### Troubleshooting
- **Missing Token:** The script requires an InfluxDB token as the first argument.
- **Permission Issue:** Creating secret files requires elevated privileges on Linux platforms.

---

## 4. `docs/scripts/deploy-stack.sh`

### Purpose
Deploys the monitoring Docker services using `docker-compose`.

### Requirements
- Docker and `docker-compose-plugin` installed.

### Operational Breakdown
1. Takes an optional argument for the directory containing `docker-compose.yml` (defaults to `/root/gh/monitoring-stack/docs/deployment`).
2. Changes to that directory and runs `docker compose up -d`.

### Troubleshooting
- **Directory Not Found:** Ensure the deployment configuration exists in the target directory.
- **Docker Daemon Down:** Start the Docker engine before running this script.

---

## 5. `docs/scripts/provision-dashboard.sh`

### Purpose
Programmatically uploads a Grafana dashboard using the Grafana API.

### Requirements
- Grafana API Token.
- A valid JSON dashboard file.

### Operational Breakdown
1. Accepts Grafana URL, Token, and JSON file path.
2. Sends a `POST` request to the `/api/dashboards/db` endpoint with the JSON payload.

### Troubleshooting
- **API Errors:** Verify your Grafana URL and Token are correct.
- **Payload Invalid:** Ensure the provided JSON file is a valid Grafana dashboard format.
