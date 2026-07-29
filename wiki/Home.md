---
title: "Home"
---

# Monitoring Stack Documentation

Welcome to the monitoring stack documentation. This repository contains the essential scripts and deployment configurations to build and maintain the monitoring infrastructure.

## Getting Started
- [Master Deployment Guide](./Master-Deployment-Guide.md) - The end-to-end walkthrough for a complete setup.

## Components
- [Bootstrap Script](./Bootstrap-Script.md)
- [Deployment Configuration](./Deployment-Configuration.md)
- [Telegraf Installation](./Telegraf-Installation.md)
- [Dashboard Provisioning](./Dashboard-Provisioning.md)

## Workflow
1. Run [bootstrap.sh](../bootstrap.sh) on a blank OS.
2. Deploy the stack using [Deployment Configuration](./Deployment-Configuration.md).
3. Use [Telegraf Installation](./Telegraf-Installation.md) to add clients.
4. Use [Dashboard Provisioning](./Dashboard-Provisioning.md) to set up Grafana.
