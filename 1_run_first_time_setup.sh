#!/usr/bin/env bash
# Prompt for, validate, and save various Ansible configuration items.

set -euo pipefail

ANSIBLE_BASE_DIR="/etc/ansible"
ANSIBLE_CONFIG="ansible.cfg"
ANSIBLE_INVENTORY="hosts"
ANSIBLE_VAULT_PASS_FILE=".vault_pass"
ANSIBLE_GROUP_VARS="playbooks/group_vars"
ANSIBLE_GROUP_VARS_FILE="${ANSIBLE_GROUP_VARS}/all"

DELETE=false
VAULT_PASS_LENGTH=50

usage() {
    echo "Usage: $0 [-d] [-l LENGTH]"
    echo "  -d            Re-prompt and overwrite all configuration files"
    echo "  -l LENGTH     Length of random generated vault password (default 50)"
    exit 1
}

while getopts "dl:" opt; do
    case $opt in
        d) DELETE=true ;;
        l) VAULT_PASS_LENGTH="$OPTARG" ;;
        *) usage ;;
    esac
done

echo "Running $0 to collect connection info for Ansible targets..."

# --- inventory ---
if $DELETE || [ ! -f "$ANSIBLE_INVENTORY" ]; then
    read -rp "Enter default user to SSH as: " ansible_user
    echo
    read -rp "Enter comma-separated list of host(s) (with optional SSH port), e.g. 192.168.1.123:2222,192.168.1.125: " ansible_inventory
    echo

    INVENTORY_TO_WRITE=""
    IFS=',' read -ra HOSTS <<< "$ansible_inventory"
    for socket in "${HOSTS[@]}"; do
        ip="${socket%%:*}"
        port="${socket##*:}"
        if [ "$ip" = "$port" ]; then
            port=22
            echo "  [i] Using default SSH port for $ip..."
        fi

        # validate IP address using `ip route get`
        if ip route get "$ip" &>/dev/null; then
            INVENTORY_TO_WRITE+="$ip:$port ansible_user=$ansible_user"$'\n'
        else
            echo "  [E] Ignoring malformed IP: $ip"
        fi
    done
    echo -n "$INVENTORY_TO_WRITE" > "$ANSIBLE_INVENTORY"
    echo
fi

# --- vault password ---
if $DELETE || [ ! -f "$ANSIBLE_VAULT_PASS_FILE" ]; then
    tr -dc '[:alnum:][:punct:]' < /dev/urandom | head -c "$VAULT_PASS_LENGTH" > "$ANSIBLE_VAULT_PASS_FILE"
    chmod 600 "$ANSIBLE_VAULT_PASS_FILE"
fi

# --- group_vars ---
if $DELETE || [ ! -d "$ANSIBLE_GROUP_VARS" ]; then
    mkdir -p "$ANSIBLE_GROUP_VARS"
fi

if $DELETE || [ ! -f "$ANSIBLE_GROUP_VARS_FILE" ]; then
    read -srp "Enter default password to SSH with: " ansible_ssh_password
    echo
    {
        ansible-vault encrypt_string --vault-password-file "$ANSIBLE_VAULT_PASS_FILE" \
            --name "ansible_ssh_password" "$ansible_ssh_password"
        echo "ansible_become_pass: '{{ ansible_ssh_password }}'"
    } > "$ANSIBLE_GROUP_VARS_FILE"
    echo
fi
