# Bootstrap Script (Manual)

The `bootstrap.sh` script is the entry point for the monitoring stack deployment. It orchestrates the entire process from OS detection to finalizing the services.

## Logic Overview
The script is designed to be idempotent and environment-aware:
1. **OS Detection**: Probes the system using common files (`/etc/debian_version`, `/etc/openwrt_release`) or the `OSTYPE` environment variable.
2. **Environment Prep**: Ensures that all scripts within `docs/scripts/` are executable by applying `chmod +x` recursive operations.
3. **Execution Branching**:
   - If Debian/Ubuntu: Triggers `install-docker.sh`.
   - If OpenWrt: Installs the required packages for OpenWrt.
   - If macOS: Uses Homebrew to install the necessary tools.
4. **Stack Activation**: Invokes `deploy-stack.sh` followed by `provision-dashboard.sh` to ensure a fully functional environment upon completion.

## Configuration Requirements
- **Root/Elevated Access**: Required to modify system directories and manage system services (systemd, etc.).
- **Connectivity**: Must have access to the Internet to download Docker packages and official repository GPG keys.

## Failure Modes & Debugging
- **"Permission Denied"**: The script requires `sudo`. Ensure the user is in the sudoers group or run as root.
- **"OS Not Supported"**: The script relies on specific file checks. If on a custom Linux distro, you may need to add a detection block for your specific release in `bootstrap.sh`.
- **"Dependency Missing"**: If `git`, `curl`, or `wget` are missing, the script will abort. Ensure a base set of network tools is installed.

## Design Choice: Why an Orchestrator?
By separating the orchestration (bootstrap) from specific tasks (docker-install, deploy-stack), we allow users to run parts of the stack manually if something fails, rather than having one massive, non-recoverable shell script.
