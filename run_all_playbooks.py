#!/usr/bin/env python3
"""
Simple script to run all playbooks

Reference:
- https://ansible-runner.readthedocs.io/en/stable/
"""

import glob
import ansible_runner

PRIVATE_DATA_DIR = "."
INVENTORY = "hosts"

def neat_border(char="-", repeat=80):
    """
    Pretty borders for simple output
    """
    print(char * repeat)

neat_border(char='=')

# Show inventory
print(ansible_runner.interface.get_inventory(action="list",
                                             inventories=[INVENTORY]))

# Find all files ending in '*.yml', ignoring some, and execute them with Ansible
returns = []
for playbook in [playbook for playbook in glob.glob("**/*.yml",
                                                    recursive=True) if
                 "function_" not in playbook]:
    neat_border()
    print(f"Running {playbook} ...")
    returns.append(ansible_runner.run(private_data_dir=PRIVATE_DATA_DIR, playbook=playbook))

# Show those delicious stats
neat_border()
print(returns)

neat_border(char='=')
