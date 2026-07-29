---
title: "Script-Reference"
---

# Engineering Specification: Script Reference

Comprehensive reference of the automated monitoring stack scripts.

## Core Orchestration
### `bootstrap.sh`
- **Purpose**: Unified entry point for fleet provisioning.
- **Parameters**: None (environment-aware).
- **Architecture**: Implements modular branching; calls sub-scripts located in `docs/scripts/`.

## Installers
### `install-docker.sh`
- **Logic**: Adds official Docker APT/RPM repos; sets up `containerd.io` and `docker-compose-plugin`.
- **Validation**: Verifies successful daemon startup via `systemctl is-active docker`.

### `install-telegraf.sh`
- **Logic**: Automates cross-platform installation (Debian, OpenWrt, macOS).
- **Security**: Injects credentials into protected sub-directory (`/etc/telegraf/secrets/`).

## Deployment & Provisioning
### `deploy-stack.sh`
- **Logic**: Thin wrapper over `docker compose up -d`.
- **Pre-flight**: Checks for required environment variables (`PROM_`, `GF_`, `LOKI_`) before execution.

### `provision-dashboard.sh`
- **Logic**: Utilizes `curl` + `jq` for API-driven dashboard deployment.
- **Resilience**: Automates UID collision resolution against target Grafana instance.

## Under the Hood: Common Failures & Error Handling

 Script | Exit Code | Common Failure | Recovery |
 :--- | :--- | :--- | :--- |
 All | 1 | Permission Denied | Re-run with root (`sudo`). |
 `deploy-stack.sh` | 137 | Out of Memory (OOM) | Reduce container memory limits in `docker-compose.yml`. |
 `provision-dashboard.sh` | 401 | Invalid Auth Token | Check `GRAFANA_API_KEY` validity. |
 `bootstrap.sh` | 127 | Missing binary | Install `jq` or `git` on target. |

## Utilities
- **`health-check.sh`**: Probes target services (9090, 3000, 3100) and returns exit code 0 if all are responsive.
- **`rotate-token.sh`**: Utility for refreshing InfluxDB tokens across the fleet.
