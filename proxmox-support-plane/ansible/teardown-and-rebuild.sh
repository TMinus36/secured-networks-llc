#!/usr/bin/env bash
# ==============================================================================
# SECURED NETWORKS LLC - DISASTER RECOVERY TEARDOWN & REBUILD
# Target Plane: LXC Support Plane
# Protocol: Idempotent state purge followed by declarative provisioning
# ==============================================================================

set -e

# 1. Purge Existing State (Forcible Teardown)
echo "[*] Phase 1: Purging legacy containers to eliminate configuration drift..."
ansible-playbook -i inventory.ini deploy-fleet.yml --extra-vars "state=absent"

# 2. Rebuild Fleet (Declarative Provisioning)
echo "[*] Phase 2: Deploying pristine Support Plane fleet per Source of Truth v5.3..."
ansible-playbook -i inventory.ini deploy-fleet.yml --extra-vars "state=present"

# 3. Bootstrap Service Mesh
echo "[*] Phase 3: Enforcing service configuration states..."
./core.sh

echo "=============================================================================="
echo "RECOVERY COMPLETE: Fleet state synchronized with Source of Truth."
echo "=============================================================================="