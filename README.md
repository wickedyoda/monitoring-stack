# Monitoring Stack

Homelab monitoring stack — Grafana, InfluxDB, Telegraf, Prometheus, and dashboards.

## Quick Links

- [Walkthrough](./monitoring-stack-walkthrough.md)
- [Grafana Dashboards](http://docker2.tail99133.ts.net:3000)

## Components

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| InfluxDB | influxdb:2.7 | 8086 | Time-series DB |
| Grafana | grafana/grafana:latest | 3000 | Dashboard UI |
| Telegraf | telegraf:1.39.1 | - | Metrics collector |
| Prometheus | prom/prometheus:v2.53.0 | 9090 | Metrics store |
| Loki | grafana/loki:3.2.0 | 3100 | Log aggregation |
| Node Exporter | prom/node-exporter:v1.8.2 | - | Host metrics |

## Dashboards

- `home-rasp1` - Raspberry Pi
- `home-docker{,1,2}` - Docker hosts
- `home-serv1`, `home-serv2` - Servers
- `home-oc` - OC host
- `home-gigi-router` - GL.iNet router
- `servers-cpu-mem` - Multi-host tiles
- `speedtest-perry` - Speed test chart

## Setup

1. Clone this repo
2. Run `docker compose up -d`
3. Configure InfluxDB first, then Grafana datasource
4. Deploy Telegraf agents to each host
5. Import dashboards via UID links