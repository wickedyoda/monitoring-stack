# Deep Dive: Dashboard Provisioning

Grafana dashboard provisioning is managed programmatically via the Grafana HTTP API, ensuring consistency across environments.

## Dashboard Structure & JSON Payload
A standard dashboard JSON contains mandatory metadata that must be handled to avoid UID/ID collisions:
- **`uid`**: Must be unique globally within the Grafana instance. 
- **`id`**: Should be `null` when provisioning to ensure Grafana assigns an ID on creation.

### API Provisioning Example
To automate, the script performs a `POST` operation:

```bash
curl -X POST -H "Authorization: Bearer $GRAFANA_API_KEY" \
     -H "Content-Type: application/json" \
     -d @dashboard.json \
     "http://grafana.internal:3000/api/dashboards/db"
```

### Advanced Payload Handling
The JSON provided in `dashboards/` is treated as a template. The automation logic strips old UIDs before submission to ensure that if a dashboard with the same slug exists, the API performs an update instead of creating a duplicate.

## Handling UID Collisions
If an import fails, the provisioning script:
1. Queries the existing dashboards via `GET /api/search?query=<slug>`.
2. Extracts the `uid` if found.
3. Patches the current dashboard file before re-attempting the `POST`.

This ensures that the deployment script is fully idempotent and resilient to concurrent updates.
