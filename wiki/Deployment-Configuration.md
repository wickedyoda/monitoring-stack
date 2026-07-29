# Deployment Configuration (Manual)

This document covers the structure and deployment of the monitoring stack services (Prometheus, Grafana, Loki) hosted on `docker2`.

## Repository Structure
- `docs/deployment/`: Contains the `docker-compose.yml` defining the stack.
- `docs/configs/`: Contains configuration files for services (e.g., `prometheus.yml`, `grafana.ini`).

## Operational Steps
1. **Prepare Environment**: Ensure `docker-compose` plugin is installed on the target host.
2. **Configure Secrets**: Create a `.env` file in the deployment directory to store sensitive values (e.g., passwords, API keys).
3. **Execution**:
   ```bash
   cd docs/deployment/
   docker compose up -d
   ```

## Requirements
- **Hardware**: Minimum 2GB RAM for a basic Prometheus/Grafana/Loki stack.
- **Docker**: Latest stable Docker CE with `docker-compose-plugin`.
- **Network**: The host must expose port 3000 (Grafana) and 9090 (Prometheus) if remote access is required.

## Failure Modes & Debugging
- **"Container Crash Loop"**: Check logs with `docker compose logs <service_name>`. Frequently caused by missing configuration files or malformed YAML.
- **"Permission Denied" (Mount)**: If the stack mounts local host volumes (like `/var/lib/prometheus`), ensure the container user (often 65534) has permissions to write to these directories.
- **"Port Conflict"**: If ports are blocked, check `ss -tulpn | grep :<port>`.

## The "Why": Choice of docker-compose
`docker compose` provides a declarative state for the entire monitoring environment. Using it allows us to handle inter-service networking (via a user-defined bridge) and dependency mapping (e.g., Grafana waiting for Prometheus to be healthy) out-of-the-box.
