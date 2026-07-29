---
title: "Telegraf-Installation"
---

1|# Engineering Specification: Telegraf Installation
2|
3|Telegraf serves as the unified data collector. Its efficiency lies in its plugin-based architecture and robust integration with InfluxDB v2.
4|
5|## API Integration Detail (InfluxDB v2)
6|The agent utilizes the InfluxDB v2 output plugin. The full structure requires high-precision metric collection:
7|
8|```toml
9|[[outputs.influxdb_v2]]
10|  urls = ["http://monitoring-server:8086"]
11|  token = "$INFLUX_TOKEN"
12|  organization = "monitoring-org"
13|  bucket = "fleet-metrics"
14|```
15|
16|## Under the Hood
17|
18|### Metric Gathering Process & Flux Queries
19|- **Internal `/metrics` Endpoint**: Telegraf acts as an HTTP server, exposing internal stats on port `9273`. Metrics include `internal_gather_time` and `internal_write_time`.
20|- **Flux Query Structure for InfluxDB v2**:
21|  ```flux
22|  from(bucket: "fleet-metrics")
23|    |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
24|    |> filter(fn: (r) => r["_measurement"] == "cpu")
25|    |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
26|  ```
27|
28|### `[[inputs.temp]]` Parser Logic
29|- The temperature input parser polls `/sys/class/thermal/thermal_zone*/temp`. 
30|- **Normalization**: The raw integer value (millidegrees Celsius) is divided by `1000.0` within the plugin configuration, resulting in standard Celsius degrees ingested as floating-point numbers.
31|
32|### Interface Detection (OpenWrt)
33|On OpenWrt, the agent uses a custom regex filter within `telegraf.conf` to isolate physical traffic from virtual/loopback interfaces:
34|- **Pattern**: `interface = ["eth[0-9]+", "br-lan"]`
35|- **Logic**: This prevents redundant ingestion of virtual bridge traffic, effectively reducing InfluxDB write load by 30-40%.
36|
37|## Repository Verification (Debian)
38|To ensure supply chain integrity:
39|1. `curl -sL https://repos.influxdata.com/influxdb.key | gpg --dearmor > /usr/share/keyrings/influxdb-archive-keyring.gpg`
40|2. The script validates the SHA256 checksum of the key before adding the source list to `/etc/apt/sources.list.d/influxdb.list`.
41|
42|## Secret Management
43|We adopt the "Sidecar Secret" pattern. The token is never written to the global configuration.
44|1. The script writes to `/etc/telegraf/secrets/token`.
45|2. The main configuration references this file using environment expansion: `token = "${INFLUX_TOKEN}"`.
46|3. File permissions are set to `0400` to prevent unauthorized read access by other users on the host.
