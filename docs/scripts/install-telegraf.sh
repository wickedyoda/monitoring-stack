#!/bin/bash
set -eu

# Detect OS and package manager
if [ -f /etc/debian_version ]; then
  OS="debian"
  PKG_MANAGER="apt-get"
elif [ -f /etc/openwrt_release ]; then
  OS="openwrt"
  PKG_MANAGER="opkg"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  PKG_MANAGER="brew"
else
  echo "Unsupported OS"
  exit 1
fi

TOKEN=${1:-""}
if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <INFLUX_TOKEN>"
  exit 1
fi

echo "Installing Telegraf on $OS using $PKG_MANAGER..."

case $OS in
  debian)
    export DEBIAN_FRONTEND=noninteractive
    $PKG_MANAGER update -qq
    $PKG_MANAGER install -y -qq gnupg curl
    curl -fsSL https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor -o /etc/apt/keyrings/influxdata-archive.gpg
    echo "deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" > /etc/apt/sources.list.d/influxdata.list
    $PKG_MANAGER update -qq
    $PKG_MANAGER install -y -qq telegraf
    mkdir -p /etc/telegraf/secrets
    echo "INFLUX_TOKEN=$TOKEN" > /etc/telegraf/secrets/influxdb_env
    chmod 600 /etc/telegraf/secrets/influxdb_env
    systemctl enable telegraf
    systemctl restart telegraf
    ;;
  openwrt)
    opkg update
    opkg install telegraf
    # OpenWrt specific config
    mkdir -p /etc/telegraf
    echo "INFLUX_TOKEN=$TOKEN" > /etc/telegraf/influxdb_env
    /etc/init.d/telegraf enable
    /etc/init.d/telegraf restart
    ;;
  macos)
    brew install telegraf
    # macOS specific config
    mkdir -p /usr/local/etc/telegraf/secrets
    echo "INFLUX_TOKEN=$TOKEN" > /usr/local/etc/telegraf/secrets/influxdb_env
    brew services start telegraf
    ;;
esac

echo "Telegraf installed and configured on $OS."
