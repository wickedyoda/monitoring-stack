# Master Deployment Guide: End-to-End Monitoring Stack

This guide provides a comprehensive walkthrough for deploying a unified monitoring stack across a mixed infrastructure fleet consisting of a core Docker host, Linux servers, and OpenWrt routers.

## Architecture Overview
The stack is built on a central InfluxDB v2 (time-series storage) and Grafana (visualization) hub, with Telegraf agents shipping metrics from individual nodes.

### Hub Components (Docker Host - `docker2`)
- **InfluxDB v2**: Central time-series database.
- **Grafana**: Visualization dashboard.
- **Prometheus/Alertmanager/Loki**: Optional additional telemetry stack.

### Edge Components
- **Linux Fleet**: Telegraf agents configured to report to InfluxDB.
- **OpenWrt Routers**: Custom Telegraf implementation for system and thermal metrics.

---

## Part 1: Central Monitoring Hub (`docker2`)

### 1. Bootstrap OS
Ensure the host is updated and Docker is installed:
```bash
apt update && apt upgrade -y
apt install -y docker.io docker-compose-plugin
```

### 2. Deployment
Configure the monitoring stack directories:
```bash
mkdir -p /root/docker/monitoring/{grafana,influxdb,telegraf,loki,prometheus,alertmanager,blackbox_exporter}
```

Deploy the core containers using the provided Docker Compose templates. After spinning up InfluxDB, capture the **Setup Token** from the logs; you will need this for all clients.

### 3. Grafana Configuration
Configure Grafana with an InfluxDB datasource pointed to `http://<hub-ip>:8086`. Disable anonymous auth and enforce internal admin control.

---

## Part 2: Linux Fleet Deployment

### 1. Telegraf Installation
On each node, install the official Telegraf binary from the InfluxData repository.

### 2. Token Injection
To keep tokens secure, avoid hardcoding them in `telegraf.conf`. Instead:
1. Define `INFLUX_TOKEN` in `/etc/default/telegraf`.
2. Override the systemd service to inject the token:
   ```bash
   cat > /etc/systemd/system/telegraf.service.d/override.conf << EOF
   [Service]
   EnvironmentFile=-/etc/default/telegraf
   Environment="INFLUX_TOKEN=$(cat /etc/default/telegraf | grep INFLUX | cut -d= -f2)"
   ExecStart=/usr/bin/telegraf -config /etc/telegraf/telegraf.conf
   EOF
   systemctl daemon-reload && systemctl restart telegraf
   ```

---

## Part 3: OpenWrt Router Deployment

### 1. SSH Access
Distribute your management SSH keys to the router's `dropbear` authorized_keys.

### 2. Telegraf Setup
- Use `opkg` to install Telegraf packages corresponding to the router's architecture.
- **NTP Sync**: Ensure NTP is configured correctly to prevent timestamp misalignment in InfluxDB.

### 3. Custom Thermal Metrics
Router thermal management requires custom scripts. Deploy `/usr/local/bin/thermal-to-influxdb` to parse router-specific thermal interfaces (e.g., `/sys/class/thermal/`), then create a Telegraf `exec` input to report these values.

---

## Part 4: Visualization and Maintenance

### 1. Dashboard Provisioning
Clone base dashboards for different device types (Host, Router, Service) and use the Grafana API to provision them globally across the hub.

### 2. Verification
Test metrics flow using:
```bash
curl -G 'http://<hub-ip>:8086/api/v2/query' \
  -H 'Authorization: Token <your-token>' \
  --data-raw 'from(bucket:"telegraf") |> range(start: -5m) |> filter(fn:(r)=>r._measurement=="cpu")'
```

---

## Troubleshooting
- **No Data**: Check `systemctl status telegraf` on the client and verify connectivity to port 8086 on the hub.
- **Time Skew**: Verify NTP status on OpenWrt routers.
- **Auth**: Re-verify `INFLUX_TOKEN` and ensure bucket name in `telegraf.conf` matches the bucket configured on the hub.
