# Monitoring Stack Walkthrough

This guide walks through installing the monitoring stack (Grafana, InfluxDB, Telegraf, Prometheus, Loki) and configuring dashboards for the homelab.

## Prerequisites

- Linux host with Docker and Docker Compose installed
- Tailscale access (for internal endpoints)
- SSH key at `~/.ssh/id_ed25519_flint4`

## Step 1: Install Docker & Docker Compose

```bash
# On Debian/Ubuntu:
apt update
apt install -y docker.io docker-compose-plugin

# Verify:
docker --version
docker compose version
```

## Step 2: Create Directory Structure

```bash
mkdir -p /root/docker/monitoring/{grafana,influxdb,telegraf,loki,prometheus,alertmanager,blackbox_exporter}
```

## Step 3: Install InfluxDB 2.x

```bash
docker run -d \
  --name=influxdb \
  -p 8086:8086 \
  -v /root/docker/influxdb:/var/lib/influxdb2 \
  -e INFLUXDB_DB=homelab \
  -e INFLUXDB_ADMIN_USER=admin \
  -e INFLUXDB_ADMIN_PASSWORD=<set-yours> \
  influxdb:2.7
```

After first run, get the setup token from logs:
```bash
docker logs influxdb 2>&1 | grep -o 'Setup token: .*'
```

Create an org/bucket via UI at `http://docker2.tail99133.ts.net:8086`.

## Step 4: Install Grafana

```bash
docker run -d \
  --name=grafana \
  -p 3000:3000 \
  -v /root/docker/grafana/app-data:/var/lib/grafana \
  -e "GF_SERVER_ROOT_URL=https://pine.tyates.one/" \
  -e "GF_AUTH_ANONYMOUS_ENABLED=false" \
  -e "GF_AUTH_BASIC_ENABLED=true" \
  -e "GF_USERS_ALLOW_SIGN_UP=false" \
  grafana/grafana:latest
```

Initial admin credentials: admin/admin (change immediately).

## Step 5: Configure Grafana Datasource

Add InfluxDB datasource at `http://docker2.tail99133.ts.net:3000/datasources`:

- **Name**: InfluxDB - telegraf
- **Type**: InfluxDB
- **URL**: `http://docker2.tail99133.ts.net:8086`
- **Database**: `telegraf`
- **User**: admin
- **Password**: <your-influx-password>
- **Min time interval**: 1m

## Step 6: Install Telegraf on Each Host

### On monitoring host (docker2):

```bash
# Edit /etc/default/telegraf
echo 'INFLUX_TOKEN="<your-influx-token>"' > /etc/default/telegraf

# Create systemd drop-in
mkdir -p /etc/systemd/system/telegraf.service.d
cat > /etc/systemd/system/telegraf.service.d/override.conf << EOF
[Service]
EnvironmentFile=-/etc/default/telegraf
Environment="INFLUX_TOKEN=$(cat /etc/default/telegraf | grep INFLUX | cut -d= -f2)"
ExecStart=
ExecStart=/usr/bin/telegraf -config /etc/telegraf/telegraf.conf --non-strict-env-handling
EOF

systemctl daemon-reload
systemctl enable --now telegraf
```

### On remote hosts (docker, docker1, serv1, serv2, oc):

```bash
# Copy telegraf.conf
scp /etc/telegraf/telegraf.conf root@<host>:/etc/telegraf/

# Set hostname
sed -i "s/host = .*/host = \"$(hostname)\"/" /etc/telegraf/telegraf.conf

# Add token
echo "INFLUX_TOKEN=\"<your-influx-token>\"" > /etc/default/telegraf

# Enable
systemctl enable --now telegraf
```

## Step 7: Prometheus Stack (Optional)

```yaml
# /root/docker/monitoring/docker-compose.yml
services:
  node_exporter:
    image: prom/node-exporter:v1.8.2
    pid: host
    network_mode: host
    volumes:
      - /proc:/hostfs/proc:ro
      - /sys:/hostfs/sys:ro
      - /:/hostfs:ro
    command:
      - "--path.procfs=/hostfs/proc"
      - "--path.sysfs=/hostfs/sys"
      - "--path.rootfs=/hostfs"

  prometheus:
    image: prom/prometheus:v2.53.0
    ports: ["9090:9090"]
    volumes:
      - /root/docker/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    command:
      - "--storage.tsdb.retention.time=30d"
    networks: [monitoring]

  alertmanager:
    image: prom/alertmanager:v0.27.0
    ports: ["9093:9093"]
    volumes:
      - /root/docker/monitoring/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    networks: [monitoring]
```

## Step 8: Import Dashboards

Import via Grafana UI or API:

| Dashboard | UID | Description |
|-----------|-----|-------------|
| Rasp1 | home-rasp1 | Raspberry Pi metrics |
| docker | home-docker | Docker host metrics |
| docker1 | home-docker1 | Docker host metrics |
| docker2 | home-docker2 | Docker host metrics |
| serv1 | home-serv1 | Server metrics |
| serv2 | home-serv2 | Server metrics |
| oc | home-oc | OC host metrics |
| Gigi's Router | home-gigi-router | Router metrics |
| Servers - CPU/MEM | servers-cpu-mem | Multi-host tile view |
| SpeedTestPerry | speedtest-perry | Speed test chart |

## Step 9: Verify Data Flow

```bash
# Check Telegraf is running
systemctl status telegraf

# Check InfluxDB has data
curl -G 'http://docker2.tail99133.ts.net:8086/api/v2/query' \
  -H 'Authorization: Token <your-token>' \
  -H 'Accept: application/json' \
  --data-raw 'from(bucket:"telegraf") |> range(start: -1h) |> filter(fn:(r)=>r._measurement=="cpu") |> limit(n:1)'
```

## Troubleshooting

1. **Blank panels**: Check datasource is assigned (panel > Edit > Datasource)
2. **Auth errors**: Verify `INFLUX_TOKEN` in `/etc/default/telegraf`
3. **No data**: Check `systemctl status telegraf` and `/var/log/syslog` for errors