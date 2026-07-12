#!/usr/bin/env bash
# File: 09-sn-lxc-ssh-remediation-final.sh
# Purpose: Inject keys, enforce SSHd state, and map true IPs for the confirmed topology.
# Execution: Run as root directly on the Proxmox Hypervisor.

set -e

read -p "PASTE the exact contents of ~/.ssh/id_ed25519_proxmox_sn.pub from LazySquirrel: " REAL_PUB_KEY

if [[ -z "$REAL_PUB_KEY" ]] || [[ "$REAL_PUB_KEY" == *"REPLACE"* ]]; then
    echo "CRITICAL ERROR: Invalid key detected. Aborting."
    exit 1
fi

# Exact LXC IDs from visual confirmation
LXC_IDS=(102 104 105 106 107 109 110 111 112 113)
INVENTORY_FILE="/tmp/sn_real_hosts_final.ini"

echo "[support_plane]" > $INVENTORY_FILE

for VMID in "${LXC_IDS[@]}"; do
    echo "Processing LXC $VMID..."
    
    STATUS=$(pct status "$VMID" | awk '{print $2}')
    if [ "$STATUS" != "running" ]; then
        echo "  -> LXC is down. Starting..."
        pct start "$VMID"
        sleep 5
    fi

    echo "  -> Enforcing SSH Daemon..."
    pct exec "$VMID" -- bash -c "which sshd > /dev/null || (apt-get update >/dev/null 2>&1 && apt-get install -y openssh-server >/dev/null 2>&1) || (apk add openssh >/dev/null 2>&1)"

    echo "  -> Injecting SSH key..."
    pct exec "$VMID" -- mkdir -p /root/.ssh
    pct exec "$VMID" -- chmod 700 /root/.ssh
    pct exec "$VMID" -- bash -c "echo '$REAL_PUB_KEY' > /root/.ssh/authorized_keys"
    pct exec "$VMID" -- chmod 600 /root/.ssh/authorized_keys
    
    pct exec "$VMID" -- bash -c "if [ -f /etc/ssh/sshd_config ]; then sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config; sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config; fi"
    pct exec "$VMID" -- bash -c "systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || service sshd restart 2>/dev/null"

    # Extract real IP from Proxmox networking config
    REAL_IP=$(pct config "$VMID" | grep -oE 'ip=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | cut -d= -f2 | head -n 1)
    HOSTNAME=$(pct config "$VMID" | grep 'hostname:' | awk '{print $2}')
    
    if [ -n "$REAL_IP" ]; then
        echo "$REAL_IP ansible_user=root # $HOSTNAME (LXC $VMID)" >> $INVENTORY_FILE
    else
        echo "  -> WARNING: No static IP configured at hypervisor level for LXC $VMID."
    fi
done

echo ""
echo "=== REPLACE [support_plane] IN YOUR ANSIBLE HOSTS.INI WITH THE FOLLOWING ==="
cat $INVENTORY_FILE