#!/usr/bin/env bash
# File: 03-sn-hypervisor-boot-sequencer.sh
# Purpose: Define Proxmox node-level startup order and dependencies for SN-LLC infrastructure.
# Execution: Run directly on the Proxmox bare-metal host.

set -e

echo "Enforcing SN-LLC Boot Sequence Topology (v5.3 - Amended)..."
echo "Assuming OPNsense Gateway (DNS/Firewall) is physically decoupled or booting at Order 0."

# ---------------------------------------------------------
# ORDER 1: DATA & SECRETS (FOUNDATIONAL BACKENDS)
# ---------------------------------------------------------
# Zone 3: PostgreSQL (LXC 109) & Vault (LXC 110)
# Delay (up): 15 seconds to ensure databases are ready for connections.
pct set 109 --onboot 1 --startup "order=1,up=15"
pct set 110 --onboot 1 --startup "order=1,up=15"

# ---------------------------------------------------------
# ORDER 2: MANAGEMENT, SECURITY, & OBSERVABILITY
# ---------------------------------------------------------
# Zone 1: Gitea / Arcane (LXC 104)
# Zone 4: Wazuh SIEM / Indexer (LXC 102)
# Zone 5: PLG Stack (LXC 111, 112, 113)
pct set 104 --onboot 1 --startup "order=2,up=15"
pct set 102 --onboot 1 --startup "order=2,up=20"
pct set 111 --onboot 1 --startup "order=2,up=5"
pct set 112 --onboot 1 --startup "order=2,up=5"
pct set 113 --onboot 1 --startup "order=2,up=5"

# ---------------------------------------------------------
# ORDER 3: EDGE / ACCESS CONTROL
# ---------------------------------------------------------
# Zone 2: Traefik, Guacamole (LXC 105, 107)
# Routing engines come online only after backends are established.
pct set 105 --onboot 1 --startup "order=3,up=5"
pct set 107 --onboot 1 --startup "order=3,up=5"

# ---------------------------------------------------------
# ORDER 4: HARDWARE VIRTUALIZATION / COMPUTE PLANE
# ---------------------------------------------------------
# Zone 6: FCOS VM (300) & SmartOS VM (101)
# Execution uses 'qm' instead of 'pct'. 
# Delay (up): 30 seconds to allow heavy OS boot before yielding to Proxmox cluster state.
#qm set 300 --onboot 1 --startup "order=4,up=30" # Not yet added
qm set 101 --onboot 1 --startup "order=4,up=30"

echo "Boot sequence applied successfully. All planes configured for automated startup."