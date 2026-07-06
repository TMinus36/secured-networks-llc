#!/usr/bin/env bash
# ==============================================================================
# SECURED NETWORKS LLC - OFFLINE VAULT BOOTSTRAP
# Target Plane: Ansible Control Node (Local Execution)
# Decoupling Protocol: Provides offline encrypted variable resolution prior to 
#                      the deployment of the HashiCorp Vault LXC appliance.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_PASS_FILE="${SCRIPT_DIR}/.vault_pass"
GROUP_VARS_DIR="${SCRIPT_DIR}/group_vars/all"
VAULT_VARS_FILE="${GROUP_VARS_DIR}/vault.yml"

echo "[*] Phase 1: Generating Offline Ansible Vault Key..."
if [ ! -f "${VAULT_PASS_FILE}" ]; then
    openssl rand -base64 32 > "${VAULT_PASS_FILE}"
    chmod 0600 "${VAULT_PASS_FILE}"
    echo "[+] Created ${VAULT_PASS_FILE}"
else
    echo "[!] ${VAULT_PASS_FILE} already exists. Skipping key generation."
fi

echo "[*] Phase 2: Initializing Group Variables Directory..."
mkdir -p "${GROUP_VARS_DIR}"

echo "[*] Phase 3: Seeding Encrypted Bootstrap Variables..."
cat <<EOF > /tmp/bootstrap_vars.yml
---
# Offline fallback variables for Zone 1 Management Bootstrap
vault_gitea_db_pass: "Sn-Gitea-Db-Boot-2026!"
EOF

# Enforce explicit vault-id resolution to override local ansible.cfg collisions
ansible-vault encrypt /tmp/bootstrap_vars.yml \
    --vault-id default@"${VAULT_PASS_FILE}" \
    --encrypt-vault-id default

mv /tmp/bootstrap_vars.yml "${VAULT_VARS_FILE}"
chmod 0600 "${VAULT_VARS_FILE}"

echo "[+] Encrypted variables secured at ${VAULT_VARS_FILE}"
echo "=============================================================================="
echo "OFFLINE VAULT CONFIGURED: Execution of core.sh will now succeed."
echo "=============================================================================="