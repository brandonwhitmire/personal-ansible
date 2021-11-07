#!/usr/bin/env python
"""
Generate dynamic inventory for Ansible by querying Vagrant
SSH config for the correct directory.
Reference:
    https://github.com/060P0TEHb/vagrant-ansible-dynamic-inventory/blob/main/inventory.py
"""

import argparse
import subprocess

import paramiko


def parse_args():
    """
    Default method to be understood by Ansible
    """
    parser = argparse.ArgumentParser(description="Vagrant inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def get_host_details(host):
    """
    Return configs for ansible for connection to vms via vagrant cli or vboxmanage
    Example with vagrant ssh-config
      Host user
        HostName 127.0.0.1
        User vagrant
        Port 2222
        ...
        IdentityFile /home/user/.vagrant.d/insecure_private_key
        ...
    """
    try:
        cmd = "vagrant ssh-config {}".format(host)
        result = subprocess.run(cmd, shell=True, check=True)
        config = paramiko.SSHConfig()
        config.parse(result.stdout)
        configfile = config.lookup(host)
    except KeyError as error:
        print(f"Exception: {error}")
    return {
        'ansible_ssh_host': configfile['hostname'],
        'ansible_ssh_port': configfile['port'],
        'ansible_ssh_user': configfile['user'],
        'ansible_ssh_private_key_file': configfile['identityfile'][0],
        'ansible_python_interpreter': '/usr/bin/python3'
    }
