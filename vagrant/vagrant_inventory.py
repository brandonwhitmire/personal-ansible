#!/usr/bin/env python
"""
Dynamic inventory plugin for Ansible's "-i"/"--inventory" option.

Reference (Adapted from Mark Mandel's implementation):
https://github.com/ansible/ansible/blob/stable-2.1/contrib/inventory/vagrant.py
"""

import argparse
import json
import subprocess
import sys

import paramiko


def list_running_hosts():
    """
    List all *running* Vagrant hosts.
    """
    hosts = []
    # Save just the "running" ones
    for line in subprocess.check_output(
            "vagrant global-status".split()).decode().strip().splitlines():
        try:
            (machine_id, name, provider, state, directory) = line.split()
            if 'running' in state:
                machine_details = subprocess.check_output(
                    f"vagrant ssh-config {machine_id}".split()).decode().strip(
                    )
                config = paramiko.SSHConfig.from_text(machine_details)
                hosts.append(config.lookup(name)["hostname"])
        except ValueError:
            # skip invalid lines
            pass
    return hosts


def get_host_details(machine_id):
    """
    The `vagrant ssh-config <ID>` command uses the machine ID and *not* IP address.
    """
    result = subprocess.check_output(f"vagrant ssh-config {machine_id}".split())
    config = paramiko.SSHConfig.from_text(result.decode())
    config_dict = config.lookup(machine_id)
    return {
        'ansible_host': config_dict['hostname'],
        'ansible_port': config_dict['port'],
        'ansible_user': config_dict['user'],
        'ansible_private_key_file': config_dict['identityfile'][0]
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Vagrant inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    args = parser.parse_args()

    if args.list:
        hosts = list_running_hosts()
        json.dump({'vagrant': hosts}, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)
