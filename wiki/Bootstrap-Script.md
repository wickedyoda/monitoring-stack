---
title: "Bootstrap-Script"
---

1|# Engineering Specification: Bootstrap Script (`bootstrap.sh`)
2|
3|The `bootstrap.sh` script is the foundational entry point for the `monitoring-stack` deployment. It is engineered for high-availability environments and heterogeneous host fleets, prioritizing idempotency and fail-fast behavior.
4|
5|## Architecture & Logic Flow
6|
7|```mermaid
8|graph TD
9|    A[Start: bootstrap.sh] --> B{OS Detection}
10|    B -- Debian/Ubuntu --> C[Execute: install-docker.sh]
11|    B -- OpenWrt --> D[Execute: setup-telegraf-opkg.sh]
12|    B -- macOS --> E[Execute: brew-bootstrap.sh]
13|    C --> F{Service Readiness}
14|    D --> F
15|    E --> F
16|    F --> G[Execute: deploy-stack.sh]
17|    G --> H[Execute: provision-dashboard.sh]
18|    H --> I[End: Status Verified]
19|```
20|
21|### 1. OS Detection Logic
22|The script probes the host environment by checking standard release files. If `OSTYPE` is undefined, it falls back to:
23|- `/etc/debian_version` for Debian-family distributions.
24|- `/etc/openwrt_release` for OpenWrt embedded systems.
25|- The `uname` output to differentiate between macOS/Darwin and standard Linux distributions.
26|
27|### 2. Security & Permissions
28|The script enforces strict permission checks:
29|- **Root/sudo Enforcement**: The script checks `$EUID`. If not 0, it logs a critical error and exits, ensuring Docker and systemd operations are performed with necessary privileges.
30|- **File Permissions**: Before execution, it runs `find docs/scripts/ -type f -name "*.sh" -exec chmod +x {} \;` to ensure all orchestration binaries are executable, mitigating permission drift.
31|
32|### 3. Idempotency & Recovery
33|- The script checks for the presence of existing configuration in `/etc/monitoring-stack/` before overwriting.
34|- If a phase fails, logs are written to `/var/log/monitoring-bootstrap.log`. The design allows re-running specific components independently of the main orchestrator.
35|
36|## Under the Hood
37|
38|### Systemd Unit Integration
39|The `bootstrap.sh` generates and enables `monitoring-stack.service` in `/etc/systemd/system/`. 
40|- **Unit Configuration**:
41|  - `ExecStart`: Calls `deploy-stack.sh` via absolute path `/usr/local/bin/deploy-stack.sh`.
42|  - `Restart`: `on-failure` with `RestartSec=5`.
43|  - `WantedBy`: `multi-user.target`.
44|
45|### Dependency Chain & Kernel Tuning
46|- **Apt/Opkg Dependencies**: Installs `curl`, `git`, `jq`, `ca-certificates`, `gnupg` (on Debian).
47|- **Kernel Parameters (`sysctl`)**:
48|  - Increases `net.core.somaxconn` to `4096` to handle high connection rates for the monitoring stack.
49|  - Increases `fs.inotify.max_user_watches` to `524288` to accommodate the large number of files in the configuration directory.
50|
51|### Exit Codes
52|- `0`: Success.
53|- `1`: Permission Denied (Requires root).
54|- `2`: OS Detection Failure (Unsupported distribution).
55|- `127`: Missing mandatory binary (`git`, `jq`).
56|
57|## Configuration Requirements
58|- **Network**: Direct access to `download.docker.com` and repository mirrors is required.
59|- **Dependencies**: Must have `curl`, `git`, and `jq` (for JSON processing) installed on the base image.
60|- **Resource Constraints**: Minimum 512MB RAM available for agent installation.
