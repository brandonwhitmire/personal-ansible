#!/usr/bin/env bash

set -e

# Running inside container check
if [[ -z "$NEW_UID" ]] ; then
        echo "[ERROR] This must be ran from inside the Docker container for the Ansible controller!"
        exit 1
fi

# Delete mode removes any ephemeral configuration and re-prompts for those values
if [[ "$1" == "-d" ]] ; then
	DELETE_MODE=1
else
	DELETE_MODE=
fi

set -u

clear

# ---

export ANSIBLE_ETC_DIR="/etc/ansible/" # location of Ansible-related configurations
export ANSIBLE_CONFIG="ansible.cfg" # general config
export ANSIBLE_INVENTORY="hosts" # inventory of machines to configure

# Prompt for host(s) if inventory file does not exist
if [[ ! -e "$ANSIBLE_INVENTORY" || $DELETE_MODE ]] ; then
	# Validate the input and write to inventory file
	python3 get_ansible_user_inputs.py
fi

# Symlink various configs to $ANSIBLE_ETC_DIR in Docker container
sudo ln --verbose --symbolic --force $(pwd)/"$ANSIBLE_CONFIG" "$ANSIBLE_ETC_DIR"
sudo ln --verbose --symbolic --force $(pwd)/"$ANSIBLE_INVENTORY" "$ANSIBLE_ETC_DIR"
