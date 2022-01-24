#!/usr/bin/env bash

set -e

if [[ -z "$NEW_UID" ]] ; then
        echo "[ERROR] This must be ran from inside the Docker Ansible controller."
        exit 1
fi

set -u

clear

# ---

ANSIBLE_ETC_DIR="/etc/ansible/"
ANSIBLE_CONFIG="ansible.cfg"

sudo ln --symbolic --force --verbose "$ANSIBLE_CONFIG" "$ANSIBLE_ETC_DIR"
