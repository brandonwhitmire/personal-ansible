#!/usr/bin/env python3
"""
Simple script to run all playbooks
"""

import glob
from pathlib import Path
import ansible_runner

playbooks = glob.glob("**/*.yml", recursive=True)

for playbook in playbooks:
    print(f"Running {playbook} ...")
    ansible_runner.run(private_data_dir=".", playbook=playbook)
