#!/usr/bin/env bash
# File: 08-sn-hypervisor-boot-sequencer.sh
# Purpose: Define Proxmox node-level startup order based on confirmed visual topology.
# Execution: Run as root directly on the Proxmox Hypervisor.

set -e

echo "Enforcing Confirmed SN-LLC Boot Sequence Topology..."

# ---------------------------------------------------------
# ORDER 1: NETWORK CORE (ROUTING, DNS, VPN)
# ---------------------------------------------------------
# VM 400: opense
# Delay (up): 60 seconds to ensure VPN tunnels and DNS unbound are fully ready.
qm set 400 --onboot 1 --startup "order=1,up=60"

# ---------------------------------------------------------
# ORDER 2: DATA & SECRETS (STATEFUL BACKENDS)
# ---------------------------------------------------------
# LXC 109: sn-db-postgres | LXC 110: sn-vault-secrets
pct set 109 --onboot 1 --startup "order=2,up=15"
pct set 110 --onboot 1 --startup "order=2,up=15"

# ---------------------------------------------------------
# ORDER 3: IDENTITY & SECURITY
# ---------------------------------------------------------
# LXC 106: sn-auth-authentik | LXC 102: sn-wazuh-siem
pct set 106 --onboot 1 --startup "order=3,up=15"
pct set 102 --onboot 1 --startup "order=3,up=20"

# ---------------------------------------------------------
# ORDER 4: MANAGEMENT & OBSERVABILITY
# ---------------------------------------------------------
# LXC 104: sn-devops-gitea
# LXC 111: sn-loki-tsdb | LXC 112: sn-prometheus-metrics | LXC 113: sn-grafana-ui
pct set 104 --onboot 1 --startup "order=4,up=10"
pct set 111 --onboot 1 --startup "order=4,up=5"
pct set 112 --onboot 1 --startup "order=4,up=5"
pct set 113 --onboot 1 --startup "order=4,up=5"

# ---------------------------------------------------------
# ORDER 5: EDGE ROUTING & ACCESS CONTROL
# ---------------------------------------------------------
# LXC 105: sn-edge-proxy | LXC 107: sn-guacamole-gateway
# These route traffic and should only start once backends are alive.
pct set 105 --onboot 1 --startup "order=5,up=5"
pct set 107 --onboot 1 --startup "order=5,up=5"

# ---------------------------------------------------------
# ORDER 6: COMPUTE PLANE (HARDWARE VIRTUALIZATION)
# ---------------------------------------------------------
# VM 101: sn-smartos-compute | VM 500: Windows11
qm set 101 --onboot 1 --startup "order=6,up=30"
qm set 500 --onboot 1 --startup "order=6,up=30"

echo "Boot sequence applied successfully across all VMs and LXCs."