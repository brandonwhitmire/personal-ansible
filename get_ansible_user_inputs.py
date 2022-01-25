#!/usr/bin/env python3

import os
import ipaddress

# Prompt user for inventory
ansible_user = input("Enter default user to SSH as: ").strip()
ansible_inventory = input("Enter comma-separated list of host(s) (with optional SSH port) to run against by default:\tExample: 192.168.1.123:2222,192.168.1.125\n")

write_out = ""
for ip_addr in ansible_inventory.strip().split(','):
    try:
        ipaddress.ip_address(ip_addr.split(':').pop(0))
    except ValueError:
        print(f"[E] Ignoring malformed IP: {ip_addr}")
    else:
        write_out += f"{ip_addr} ansible_user={ansible_user}\n"
with open(os.environ['ANSIBLE_INVENTORY'], "wt") as file:
    file.write(write_out)
