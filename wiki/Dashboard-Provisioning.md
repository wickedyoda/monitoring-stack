1|# Engineering Specification: Dashboard Provisioning
2|
3|Grafana dashboard provisioning is managed programmatically via the Grafana HTTP API, ensuring consistency across environments.
4|
5|## Dashboard Structure & JSON Payload
6|A standard dashboard JSON contains mandatory metadata that must be handled to avoid UID/ID collisions:
7|- **`uid`**: Must be unique globally within the Grafana instance. 
8|- **`id`**: Should be `null` when provisioning to ensure Grafana assigns an ID on creation.
9|
10|## Under the Hood: Grafana JSON Schema
11|The dashboard schema is highly hierarchical. Key sections include:
12|- **`panels`**: An array containing objects defining visualization parameters (`type`, `title`, `datasource`). 
13|  - `targets`: Defines the query sent to InfluxDB, including `refId` (used for joins), `query`, and `format`.
14|  - `fieldConfig`: Contains thresholds, units, and custom mappings.
15|- **`templating`**: Defines interactive variables used for dashboards (e.g., `$hostname`). 
16|  - `datasource`: The reference to the data source.
17|  - `refresh`: Frequency of variable list updates.
18|
19|### API Provisioning Example
20|To automate, the script performs a `POST` operation:
21|
22|```bash
23|curl -X POST -H "Authorization: Bearer ***" \
24|     -H "Content-Type: application/json" \
25|     -d @dashboard.json \
26|     "http://grafana.internal:3000/api/dashboards/db"
27|```
28|
29|### Advanced Payload Handling
30|The JSON provided in `dashboards/` is treated as a template. The automation logic strips old UIDs before submission to ensure that if a dashboard with the same slug exists, the API performs an update instead of creating a duplicate.
31|
32|## Handling UID Collisions
33|If an import fails, the provisioning script:
34|1. Queries the existing dashboards via `GET /api/search?query=<slug>`.
35|2. Extracts the `uid` if found.
36|3. Patches the current dashboard file before re-attempting the `POST`.
37|
38|This ensures that the deployment script is fully idempotent and resilient to concurrent updates.
