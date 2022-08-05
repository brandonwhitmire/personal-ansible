#!/usr/bin/env python3
"""
Simple script to run all playbooks

Reference:
- https://ansible-runner.readthedocs.io/en/stable/
"""

import glob
import pprint
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
inventory = ansible_runner.interface.get_inventory(action="list",
                                                   response_format="json",
                                                   quiet=True,
                                                   inventories=[INVENTORY])[0]
print("Hosts from Inventory:\n")
pprint.pprint(inventory["_meta"]["hostvars"])

# Find all files ending in '*.yml', ignoring some, and execute them with Ansible
returns = []
for playbook in [
        playbook for playbook in glob.glob("**/*.yml", recursive=True)
        if "function_" not in playbook
]:
    neat_border()
    print(f"Running {playbook} ...")
    returns.append((playbook,
                    ansible_runner.run(private_data_dir=PRIVATE_DATA_DIR,
                                       quiet=False,
                                       playbook=playbook).stats))

# Show those delicious stats
neat_border()
for ret in returns:
    pprint.pprint(ret)
    neat_border(char=".", repeat=40)

neat_border(char='=')
