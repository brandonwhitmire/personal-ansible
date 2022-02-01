#!/usr/bin/env python3
"""
Prompt for, validate, and save various Ansible configuration items.
"""

import argparse
import os
import sys
from pathlib import Path
import subprocess
import ipaddress
import getpass
import secrets
import string

try:
    os.environ['NEW_UID']
except KeyError:
    print(
        "[E] This must be ran from inside the Docker container for the Ansible controller!"
    )
    sys.exit(1)

if __name__ == "__main__":

    print(f"Running {sys.argv[0]} to collect connection info for Ansible targets...")

    # --- argparse ---

    parser = argparse.ArgumentParser(
        description=
        "Prompt for, validate, and save various Ansible configuration items",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("-d",
                        "--delete",
                        action="store_true",
                        help="Re-prompt and overwrite all configuration files",
                        default=False)
    parser.add_argument("-l",
                        "--vault_pass_length",
                        type=int,
                        metavar="LENGTH",
                        help="Length of random generated vault password",
                        default=50)

    args = parser.parse_args()

    # --- actions ---

    # Various Ansible configuration files
    ANSIBLE_BASE_DIR = Path(
        "/etc/ansible")  # location of Ansible-related configurations
    ANSIBLE_CONFIG = Path("ansible.cfg")  # general config
    ANSIBLE_INVENTORY = Path("hosts")  # inventory of machines to configure
    ANSIBLE_VAULT_PASS_FILE = Path(".vault_pass")
    ANSIBLE_GROUP_VARS = Path("playbooks/group_vars")
    ANSIBLE_GROUP_VARS_FILE = Path(f"{ANSIBLE_GROUP_VARS}/all")

    if args.delete or not ANSIBLE_INVENTORY.exists():
        # Prompt user and host(s) for inventory
        ansible_user = input("Enter default user to SSH as: ").strip()
        ansible_inventory = input(
            """\nEnter comma-separated list of host(s) (with optional SSH port) to run against by default:
            Example: 192.168.1.123:2222,192.168.1.125\n""")

        # Validate IP address and port
        INVENTORY_TO_WRITE = ""
        for socket in ansible_inventory.strip().split(','):
            socket = socket.split(':')
            ip_addr = socket.pop(0)

            try:
                port = socket.pop()
                assert 0 < int(port) <= 65535, "Port integer is invalid!"
            except IndexError:
                port = str(22)
                print(f"\t[i] Using default SSH port for {ip_addr}...")

            try:
                ipaddress.ip_address(ip_addr)
            except ValueError:
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print(f"[E] Ignoring malformed IP: {ip_addr}")
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            else:
                # Only save the IP if it is valid
                INVENTORY_TO_WRITE += f"{ip_addr}:{port} ansible_user={ansible_user}\n"
        with open(ANSIBLE_INVENTORY, "wt", encoding="utf-8") as file:
            file.write(INVENTORY_TO_WRITE)
        print()

    if args.delete or not ANSIBLE_VAULT_PASS_FILE.exists():
        # Generate random vault password
        with open(ANSIBLE_VAULT_PASS_FILE, "wt", encoding="utf-8") as file:
            file.write("".join([
                secrets.choice(string.printable.strip())
                for i in range(args.vault_pass_length)
            ]))
        ANSIBLE_VAULT_PASS_FILE.chmod(0o600)

    if args.delete or not ANSIBLE_GROUP_VARS.exists():
        ANSIBLE_GROUP_VARS.mkdir(parents=True, exist_ok=True)

    if args.delete or not ANSIBLE_GROUP_VARS_FILE.exists():
        # Secure SSH password using vault password
        ansible_ssh_password = getpass.getpass(
            "Enter default password to SSH with: ")
        with open(ANSIBLE_GROUP_VARS_FILE, "wt", encoding="utf-8") as file:
            file.write(
                subprocess.check_output(
                    f"ansible-vault encrypt_string --name 'ansible_ssh_password' '{ansible_ssh_password}'",
                    shell=True,
                    timeout=5).decode())
            file.write("ansible_become_pass: '{{ ansible_ssh_password }}'")
        print("\n")
