#!/usr/bin/env bash
# ==============================================================================
# SECURED NETWORKS LLC - TARGETED SERVICE ORCHESTRATION
# Target Plane: LXC Support Plane (Network Level Deployment via SSH)
# Decoupling Protocol: Execution bypasses hypervisor state, mapping directly 
#                      to internal LXC SSH targets via absolute inventory path.
# ==============================================================================

set -e

# Dynamically resolve absolute path to prevent environmental drift
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="${SCRIPT_DIR}/inventory/hosts.ini"

echo "Phase 1/5: Executing Common Bootstrap (Support Plane Nodes)..."
ansible-playbook -i "${INVENTORY_FILE}" core.yml --tags "common"

echo "Phase 2/5: Provisioning Gitea GitOps Engine (Management Zone)..."
ansible-playbook -i "${INVENTORY_FILE}" core.yml --tags "gitea"

echo "Phase 3/5: Establishing Tailscale SD-WAN Node (Edge Zone)..."
ansible-playbook -i "${INVENTORY_FILE}" core.yml --tags "tailscale"

echo "Phase 4/5: Deploying Guacamole Remote Access Gateway (Edge Zone)..."
ansible-playbook -i "${INVENTORY_FILE}" core.yml --tags "guacamole"

echo "Phase 5/5: Initializing Traefik Reverse Proxy (Edge Zone)..."
ansible-playbook -i "${INVENTORY_FILE}" core.yml --tags "traefik"

echo "=============================================================================="
echo "STATE ENFORCEMENT COMPLETE: Core services provisioned via tagged execution."
echo "=============================================================================="