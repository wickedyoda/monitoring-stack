---
title: "Script-Reference"
---

1|# Engineering Specification: Script Reference
2|
3|Comprehensive reference of the automated monitoring stack scripts.
4|
5|## Core Orchestration
6|### `bootstrap.sh`
7|- **Purpose**: Unified entry point for fleet provisioning.
8|- **Parameters**: None (environment-aware).
9|- **Architecture**: Implements modular branching; calls sub-scripts located in `docs/scripts/`.
10|
11|## Installers
12|### `install-docker.sh`
13|- **Logic**: Adds official Docker APT/RPM repos; sets up `containerd.io` and `docker-compose-plugin`.
14|- **Validation**: Verifies successful daemon startup via `systemctl is-active docker`.
15|
16|### `install-telegraf.sh`
17|- **Logic**: Automates cross-platform installation (Debian, OpenWrt, macOS).
18|- **Security**: Injects credentials into protected sub-directory (`/etc/telegraf/secrets/`).
19|
20|## Deployment & Provisioning
21|### `deploy-stack.sh`
22|- **Logic**: Thin wrapper over `docker compose up -d`.
23|- **Pre-flight**: Checks for required environment variables (`PROM_`, `GF_`, `LOKI_`) before execution.
24|
25|### `provision-dashboard.sh`
26|- **Logic**: Utilizes `curl` + `jq` for API-driven dashboard deployment.
27|- **Resilience**: Automates UID collision resolution against target Grafana instance.
28|
29|## Under the Hood: Common Failures & Error Handling
30|
 Script | Exit Code | Common Failure | Recovery |
 :--- | :--- | :--- | :--- |
 All | 1 | Permission Denied | Re-run with root (`sudo`). |
 `deploy-stack.sh` | 137 | Out of Memory (OOM) | Reduce container memory limits in `docker-compose.yml`. |
 `provision-dashboard.sh` | 401 | Invalid Auth Token | Check `GRAFANA_API_KEY` validity. |
 `bootstrap.sh` | 127 | Missing binary | Install `jq` or `git` on target. |
37|
38|## Utilities
39|- **`health-check.sh`**: Probes target services (9090, 3000, 3100) and returns exit code 0 if all are responsive.
40|- **`rotate-token.sh`**: Utility for refreshing InfluxDB tokens across the fleet.
