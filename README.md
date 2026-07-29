# Monitoring Stack

A comprehensive, script-driven monitoring infrastructure for your homelab.

## Disclaimer
This repository is provided "as is" without warranty of any kind. The user assumes all responsibility for any use, deployment, or configuration of these scripts. By using this software, you agree to the [Disclaimer and Limitation of Liability](https://www.wickedyoda.com/privacy-policy-terms-of-use-disclaimer-and-limitation-of-liability/).

## Overview
Automated, reproducible monitoring including:
- **Central Host:** Dockerized stack (Prometheus, Grafana, InfluxDB, Loki).
- **Fleet Nodes:** Telegraf agents for Linux and macOS.
- **Router Fleet:** Monitoring for OpenWrt devices.

## Getting Started
See the [Wiki](wiki/Home.md) for full walkthroughs.

## Workflow
1.  **Bootstrap:** Run `./bootstrap.sh` on a new host.
2.  **Deploy:** Use `docs/deployment/` to stand up the monitoring stack.
3.  **Clients:** Use `docs/scripts/install-telegraf.sh` to add nodes.
4.  **Provision:** Use `docs/scripts/provision-dashboard.sh` to import Grafana dashboards.
