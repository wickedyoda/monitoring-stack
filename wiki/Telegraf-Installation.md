# Telegraf Installation (Manual)

Telegraf acts as the metric collection agent for all fleet nodes, feeding data into the central InfluxDB instance.

## Installation Process
1. **Host Detection**: The `docs/scripts/install-telegraf.sh` script detects if the host is Debian/Ubuntu, OpenWrt, or macOS.
2. **Installation**:
   - Debian: Adds the InfluxData repository and installs via `apt`.
   - OpenWrt: Installs the `telegraf` package via `opkg`.
   - macOS: Uses `brew install telegraf`.
3. **Environment Security**: The script injects the InfluxDB API token into `/etc/telegraf/secrets/influxdb_env` (or equivalent location) instead of putting it directly in `telegraf.conf`.

## Requirements
- **InfluxDB Token**: You need a token with write-access to the target InfluxDB bucket.
- **Network Access**: The agent must reach the InfluxDB API endpoint on the central monitoring server (typically port 8086).

## Operational Steps
```bash
# Provide the token as the first argument
./docs/scripts/install-telegraf.sh <INFLUX_TOKEN>
```

## Failure Modes & Debugging
- **"Token Not Accepted"**: Check if the token has the correct scope (write-access to the bucket).
- **"Connection Refused"**: Check firewalls (UFW on Ubuntu, or security groups in cloud environments) to ensure the agent can reach the central server on port 8086.
- **"Telegraf Service Fails to Start"**: Run `systemctl status telegraf` or check the logs `/var/log/telegraf/telegraf.log`.

## The "Why": Secret Separation
We intentionally store the InfluxDB token in a separate environment file rather than the main `telegraf.conf`. This allows us to update the token without overwriting the base configuration, minimizing the risk of misconfiguration during updates.
