# My Ansible Playbooks - Arch Linux OS

My personal collection of Ansible playbooks to automate the setup and configuration of my Arch Linux system. This is targeted to my personal tastes as my "daily driver".

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Setup Guide](#setup-guide)
    - [Controller](#controller)
    - [Targets](#targets)
5. [Usage](#usage)
6. [Common Commands](#common-commands)
7. [Testing & Validation](#testing--validation)
8. [Troubleshooting](#troubleshooting)
9. [Extending / Customizing](#extending--customizing)
10. [References](#references)

---

## Overview

This project provides modular Ansible playbooks for initializing fresh Arch Linux installations

---

## Features
- Tailored for Arch Linux (uses `pacman` and Arch-specific tools)
- Modular playbooks for desktop, server, and development environments
- Automated testing with [Molecule](https://molecule.readthedocs.io/)
- Example ad-hoc and troubleshooting commands
- Easily extensible for your own needs

---

## Requirements

### Controller (Your machine running Ansible)
- Python 3.x
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [sshpass](https://linux.die.net/man/1/sshpass) (for password-based SSH)
- Virtualenv (recommended)

### Targets (Machines to be configured)
- Arch Linux (or derivative)
- SSH server (`sshd`) running and accessible
- (Optional) SSH key authentication set up

---

## Setup Guide

### Controller

1. **Install dependencies:**
   ```bash
   sudo pacman -S --noconfirm sshpass
   python3 -m venv "$(git rev-parse --show-toplevel)/venv"
   source venv/bin/activate
   pip3 install --requirement requirements.txt
   ansible-galaxy collection install --requirements-file requirements.yml
   ```
2. **First-time setup:**
   ```bash
   ./1_run_first_time_setup.py
   ```

### Targets

- **Enable SSH:**
  ```bash
  sudo systemctl enable --now sshd
  ```
- **(Optional) Set up SSH key authentication:**
  ```bash
  ssh-copy-id -i ~/.ssh/id_rsa <USER>@<IP_ADDR>
  ```

---

## Usage

1. **Activate the Python virtual environment:**
   ```bash
   source venv/bin/activate
   ```
2. **Run the main playbook:**
   ```bash
   ansible-playbook playbooks/main.yml
   ```

---

## Common Commands

- **Show inventory:**
  ```bash
  ansible-inventory --list
  ansible-inventory --graph
  ```
- **Dry-run (check mode) with verbose output:**
  ```bash
  ansible-playbook --check -vvvvv <PLAYBOOK>
  ```
- **Debug variables:**
  ```bash
  ansible all -m debug -a "var=hostvars"
  ansible all -m debug -a "var=vars"
  ansible -m debug -a 'msg={{ ansible_user }}' all
  ```
- **Run playbook against a specific host (no inventory file):**
  > Note: When not providing a file to `-i`, the trailing comma is required for the hostname or IP address.
  ```bash
  ANSIBLE_PIPELINING=true \
  ANSIBLE_INVENTORY_ENABLED="host_list" ansible-playbook \
      --inventory <HOST>, \
      --extra-vars "ansible_ssh_extra_args='-o StrictHostKeyChecking=no' ansible_user=<USER> ansible_ssh_password=<PASSWORD> ansible_ssh_become_password=<PASSWORD>" \
      <PLAYBOOKS>
  ```

### Ad-Hoc Commands

Run commands on hosts without a playbook or role.

- **Reboot remote host with privilege escalation:**
  ```bash
  ANSIBLE_INVENTORY_ENABLED="host_list" \
  ansible \
      --inventory <HOST>, \
      --extra-vars "ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=1200' ansible_user=<USER> ansible_ssh_password=<PASSWORD> ansible_ssh_become_password=<PASSWORD>" \
      --become \
      --args 'reboot now' \
      all  # 'all' is a host pattern (required)
  ```
  > **Tip:** Use `--become` for commands requiring sudo/root privileges.

---

## Testing & Validation

- **Lint and syntax check:**
  ```bash
  yamllint
  ansible-playbook --syntax-check
  ansible-lint
  ```
- **Integration testing with Molecule:**
  ```bash
  # Arch image is required
  curl -L https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2 -o /var/lib/libvirt/images/

  sudo pacman -S cdrkit

  molecule test # Full test (destroys environment after)
  molecule converge # Apply playbook, keep environment running for manual checks
  molecule destroy && molecule reset # Clean up all test resources
  molecule test --destroy never --platform-name arch-instance # E2E on specific platform
  ```
  > **Tip:** Use `--debug -vvvvv` with Molecule for verbose troubleshooting.

- **Check mode (dry run) against target:**
  ```bash
  ansible-playbook --check
  ```

#### Molecule Logging
- **Follow Vagrant logs (if using Vagrant driver):**
  ```bash
  tail --follow ~/.cache/molecule/ansible/*/vagrant.{out,err}
  ```
- **Follow Ansible logs:**
  ```bash
  tail --follow /tmp/ansible.molecule.log
  ```

---

## Troubleshooting

- **Directory matters:** Always run Ansible commands from the project root to avoid unexpected behavior due to misplaced config files.
- **Enable interactive debugger on task failure:**
  ```bash
  ANSIBLE_ENABLE_TASK_DEBUGGER=True
  ```
- **SSH errors with Molecule/Vagrant:** Check both `vagrant.out` and `vagrant.err` logs for details. Sometimes only `vagrant.out` contains the root cause.
- **General tip:** If you get strange errors, try running `cd /ansible_controller` to reset your working directory, or re-enter the controller environment if using Docker.

---

## Extending / Customizing

- Add or modify playbooks in the `playbooks/` directory to suit your needs.
- Place custom files, templates, or scripts in `playbooks/files/`.
- Use Molecule scenarios in `molecule/` to test new roles or playbooks.
- Update `requirements.txt` and `requirements.yml` for new Python or Ansible dependencies.

---

## References

- [Ansible Official Docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
- [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [YouTube: Ansible Playbook Walkthrough](https://youtu.be/FaXVZ60o8L8?t=1239)
