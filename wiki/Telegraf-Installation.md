---
title: "Telegraf-Installation"
---

# Engineering Specification: Telegraf Installation

Telegraf serves as the unified data collector. Its efficiency lies in its plugin-based architecture and robust integration with InfluxDB v2.

## API Integration Detail (InfluxDB v2)
The agent utilizes the InfluxDB v2 output plugin. The full structure requires high-precision metric collection:

```toml
[[outputs.influxdb_v2]]
  urls = ["http://monitoring-server:8086"]
  token = "$INFLUX_TOKEN"
  organization = "monitoring-org"
  bucket = "fleet-metrics"
```

## Under the Hood

### Metric Gathering Process & Flux Queries
- **Internal `/metrics` Endpoint**: Telegraf acts as an HTTP server, exposing internal stats on port `9273`. Metrics include `internal_gather_time` and `internal_write_time`.
- **Flux Query Structure for InfluxDB v2**:
  ```flux
  from(bucket: "fleet-metrics")
    |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
    |> filter(fn: (r) => r["_measurement"] == "cpu")
    |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  ```

### `[[inputs.temp]]` Parser Logic
- The temperature input parser polls `/sys/class/thermal/thermal_zone*/temp`. 
- **Normalization**: The raw integer value (millidegrees Celsius) is divided by `1000.0` within the plugin configuration, resulting in standard Celsius degrees ingested as floating-point numbers.

### Interface Detection (OpenWrt)
On OpenWrt, the agent uses a custom regex filter within `telegraf.conf` to isolate physical traffic from virtual/loopback interfaces:
- **Pattern**: `interface = ["eth[0-9]+", "br-lan"]`
- **Logic**: This prevents redundant ingestion of virtual bridge traffic, effectively reducing InfluxDB write load by 30-40%.

## Repository Verification (Debian)
To ensure supply chain integrity:
1. `curl -sL https://repos.influxdata.com/influxdb.key | gpg --dearmor > /usr/share/keyrings/influxdb-archive-keyring.gpg`
2. The script validates the SHA256 checksum of the key before adding the source list to `/etc/apt/sources.list.d/influxdb.list`.

## Secret Management
We adopt the "Sidecar Secret" pattern. The token is never written to the global configuration.
1. The script writes to `/etc/telegraf/secrets/token`.
2. The main configuration references this file using environment expansion: `token = "${INFLUX_TOKEN}"`.
3. File permissions are set to `0400` to prevent unauthorized read access by other users on the host.
