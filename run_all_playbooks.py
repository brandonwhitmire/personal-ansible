#!/usr/bin/env python3
"""
Simple script to run all playbooks
"""

import glob
import ansible_runner

# Find all files ending in `.yml` and execute them with Ansible
for playbook in glob.glob("**/*.yml", recursive=True):
    print("=" * 80)
    print(f"Running {playbook} ...")
    ansible_runner.run(private_data_dir=".", playbook=playbook)
