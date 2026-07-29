1|# Engineering Specification: Deployment Configuration
2|
3|The monitoring stack architecture relies on a declarative Docker Compose approach to ensure service discovery, isolation, and lifecycle management.
4|
5|## Network Topology
6|
7|```mermaid
8|graph LR
9|    subgraph Host[Host: docker2]
10|        direction TB
11|        Bridge[Docker Bridge: monitoring]
12|        Prometheus[Prometheus]
13|        Grafana[Grafana]
14|        Loki[Loki]
15|        
16|        Prometheus <--> Bridge
17|        Grafana <--> Bridge
18|        Loki <--> Bridge
19|    end
20|    Bridge -- Port 3000 --> External[Public/VPN Access]
21|    Bridge -- Port 9090 --> External
22|```
23|
24|### 1. Service Isolation
25|Services are hosted on a dedicated `monitoring` bridge network. This enforces:
26|- **DNS Service Discovery**: Services interact using container names (e.g., `prometheus:9090`) rather than IP addresses.
27|- **Traffic Shaping**: The bridge prevents external interference while allowing controlled egress for data scraping.
28|
29|## Under the Hood: Docker Compose Breakdown
30|
31|### Core Labels & Volumes
32|- **Labels**: 
33|  - `com.monitoring.stack.version`: `${STACK_VERSION}` - Tracks version for rollbacks.
34|  - `traefik.enable`: `true` - Standardizes ingress through Traefik (if present).
35|  - `traefik.http.routers.grafana.rule`: `Host(grafana.example.com)` - Provides domain-based routing.
36|
37|### Environment Variable Mapping
38|- **`GF_DATABASE_URL`**: Maps to an external PostgreSQL DB (if configured), optimizing Grafana state persistence over SQLite.
39|- **`LOKI_RETENTION_PERIOD`**: Set to `720h` (30 days), determining the storage lifecycle.
40|- **`PROMETHEUS_SCRAPE_INTERVAL`**: `15s` - Defines the sampling resolution for all discovered targets.
41|
42|### Container Resource Limits (Cgroups)
43|- **Prometheus**: CPU `1.0`, Memory `2GB`. 
44|- **Grafana**: CPU `0.5`, Memory `512MB`.
45|- **Loki**: CPU `1.0`, Memory `1GB`.
46|
47|## Exhaustive Configuration Checklist
48|| Service | Persistent Path | Port | Env Variable Prefix |
49|| :--- | :--- | :--- | :--- |
50|| Prometheus | `/var/lib/prometheus` | 9090 | `PROM_` |
51|| Grafana | `/var/lib/grafana` | 3000 | `GF_` |
52|| Loki | `/data/loki` | 3100 | `LOKI_` |
53|
54|## Deployment Strategy
55|The stack is deployed via `docker compose up -d --build`. This forces a check of the image manifests and ensures local configurations are properly synced with container states.
