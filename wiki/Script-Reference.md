# Script Reference (Manual)

This document provides a technical deep-dive into the automation scripts used within the `monitoring-stack` repository.

## 1. `bootstrap.sh`
- **Purpose**: Orchestrates the initial environment setup.
- **Why**: Ensures uniform deployment across heterogeneous hosts (Debian, OpenWrt, macOS).
- **Failure**: Fails early if the OS is not recognized, preventing partial/incorrect installs.

## 2. `docs/scripts/install-docker.sh`
- **Purpose**: Installs Docker and the Docker Compose plugin.
- **Requirements**: Debian/Ubuntu base only.
- **Logic**: Adds official repositories, verifies GPG keys, and installs required packages via `apt`.
- **Why**: Direct repo usage ensures we have the latest Docker binaries, avoiding issues with outdated OS-provided packages.

## 3. `docs/scripts/install-telegraf.sh`
- **Purpose**: Deploys the Telegraf agent.
- **Requirements**: Needs an InfluxDB Token.
- **Logic**: Detects the native package manager (apt/opkg/brew), installs the agent, and injects secrets into a dedicated environment file.
- **Debugging**: Inspect logs in `/var/log/telegraf/telegraf.log`.

## 4. `docs/scripts/deploy-stack.sh`
- **Purpose**: Spins up the monitoring Docker services.
- **Logic**: Calls `docker compose up -d` in the configuration directory.
- **Requirements**: Functional Docker Engine.
- **Debugging**: Use `docker compose logs` for service-specific errors.

## 5. `docs/scripts/provision-dashboard.sh`
- **Purpose**: Automates Grafana dashboard deployment.
- **Logic**: Uses `curl` against the Grafana API endpoint (`/api/dashboards/db`).
- **Why**: Essential for infrastructure-as-code and enabling ephemeral dashboard environments.
