#!/bin/bash
set -eux
# Generic Linux Telegraf installation script
# Usage: ./install-telegraf.sh <INFLUX_TOKEN>

TOKEN=${1:-""}
if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <INFLUX_TOKEN>"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq gnupg curl

# Add InfluxData repository
curl -fsSL https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor -o /etc/apt/keyrings/influxdata-archive.gpg
echo "deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" > /etc/apt/sources.list.d/influxdata.list
apt-get update -qq
apt-get install -y -qq telegraf

# Write secrets
mkdir -p /etc/telegraf/secrets
echo "INFLUX_TOKEN=$TOKEN" > /etc/telegraf/secrets/influxdb_env
chmod 600 /etc/telegraf/secrets/influxdb_env

# Configure Telegraf to use secrets
# Ensure /etc/telegraf/telegraf.conf includes:
# [[outputs.influxdb_v2]]
#   token = "${INFLUX_TOKEN}"

systemctl enable telegraf
systemctl restart telegraf
echo "Telegraf installed and configured."
