# Monitoring Stack

A comprehensive, script-driven monitoring infrastructure for your homelab. 

## Overview
This repository provides a fully automated, reproducible monitoring stack including:
- **Central Host:** Dockerized stack (Prometheus, Grafana, InfluxDB, Loki).
- **Fleet Nodes:** Telegraf agents installed on Linux (Debian/Ubuntu) and macOS.
- **Router Fleet:** Monitoring for OpenWrt devices (including custom thermal metrics).

## Workflow
1.  **Bootstrap:** Run `./bootstrap.sh` on a new host to install Docker.
2.  **Deploy:** Use `docs/deployment/` to stand up the monitoring stack.
3.  **Clients:** Use `docs/scripts/install-telegraf.sh` to add nodes.
4.  **Provision:** Use `docs/scripts/provision-dashboard.sh` to import Grafana dashboards.

## Documentation
Full detailed walkthroughs and step-by-step instructions are available in the [Wiki](wiki/Home.md).

## Verification
CI/CD verification (linting, syntax checks, security scanning) runs on every push to `master`.
