# My Ansible Playbooks - Arch Linux OS

My personal collection of Ansible playbooks to automate the setup and configuration of my Arch Linux system. This is targeted to my personal tastes as my "daily driver".

---

## Overview

This project provides modular Ansible playbooks for initializing fresh Arch Linux installations

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
   source venv/bin/activate && ./1_run_first_time_setup.sh
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

1. **Activate the Python venv and run the main Playbook:**
   ```bash
   source venv/bin/activate && ansible-playbook archlinux.yml
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
- **Check mode (dry run) against target:**
  ```bash
  ansible-playbook --check
  ```

### End-to-End Testing

This requires a basic Arch Linux VM imported into Vagrant. My other project builds a [Arch Linux VM for libvirt (QEMU) using Packer](https://github.com/OpenSourceKyle/personal-packer) using an installation script that is true to my actual hardware. Assuming a Arch Linux VM exists (will require updating the Vagrantfile if not using my project), simply run the following command to run an end-to-end of the playbooks:

```bash
# Provision and configure VM; later, shut it down upon success
vagrant up --provision && vagrant halt
# Delete VM
vagrant destroy
```

---

## Troubleshooting

- **Directory matters:** Always run Ansible commands from the project root to avoid unexpected behavior due to misplaced config files.
- **Enable interactive debugger on task failure:**
  ```bash
  ANSIBLE_ENABLE_TASK_DEBUGGER=True
  ```
- **SSH errors with Vagrant:** Check both `vagrant.out` and `vagrant.err` logs for details. Sometimes only `vagrant.out` contains the root cause.

---

## References

- [Ansible Official Docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
- [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
- [YouTube: Ansible Playbook Walkthrough](https://youtu.be/FaXVZ60o8L8?t=1239)
