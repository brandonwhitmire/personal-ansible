#!/usr/bin/env python
# Adapted from Mark Mandel's implementation
# https://github.com/ansible/ansible/blob/stable-2.1/contrib/inventory/vagrant.py

import argparse
import json
import subprocess
import sys

import paramiko

def parse_args():
    parser = argparse.ArgumentParser(description="Vagrant inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def list_running_hosts():
    cmd = "vagrant status --machine-readable"
    status = subprocess.check_output(cmd.split()).decode().rstrip()
    hosts = []
    for line in status.splitlines():
        (_, host, key, value) = line.split(',')[:4]
        if key == 'state' and value == 'running':
            hosts.append(host)
    return hosts


def get_host_details(host):
    cmd = "vagrant ssh-config {}".format(host)
    p = subprocess.run(cmd.split(),
                       shell=True,
                       check=False,
                       capture_output=True)
    config = paramiko.SSHConfig()
    config.parse(p.stdout.decode())
    c = config.lookup(host)
    return {
        'ansible_host': c['hostname'],
        'ansible_port': c['port'],
        'ansible_user': c['user'],
        'ansible_private_key_file': c['identityfile'][0]
    }


if __name__ == '__main__':
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        json.dump({'vagrant': hosts}, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)
