# Ansible

Ansible playbooks for various setups and configurations.

# Pre-requisites

## Targets
- `sshd` running (and allowed through firewall) on target nodes:

```bash
sudo systemctl start sshd # SSH on until reboot
sudo systemctl enable --now sshd # SSH permanentely on
```

- If using SSH key authentication, then add the pubkey to `~/.ssh/authorized_keys`:

[SSH Auth via Keys](https://www.ssh.com/academy/ssh/copy-id)

```bash
ssh-copy-id -i ~/.ssh/id_rsa <USER>@<IP_ADDR>
```

## Controller

- Docker is required

```bash
# For Arch-based systems
sudo pacman -S docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER # requires logout/reboot
```

# Quick Start

Use the Dockerized Ansible controller to configure target nodes:

```bash
# Automatically build the batteries-included Ansible controller node
# NOTE: this container will prompt the user for necessary connection information
./1_run_ansible_controller.sh

# Configure VMs by running playbooks against VMs as returned from ansible-inventory
# NOTE: <PLAYBOOK> is any of the *.yml* files in this repo root directory
ansible-playbook <PLAYBOOK>
```

# Common Commands

```bash
# Show inventory
ansible-inventory --list
ansible-inventory --graph

# Specify hosts manually instead of using an inventory file
# NOTE: when not providing a file to "-i" the trailing ',' is required for a hostname or IP address
ANSIBLE_INVENTORY_ENABLED="host_list" ansible-playbook --ask-pass --ask-become-pass --user <SSH_USER> --inventory <IP_ADDR>, <PLAYBOOK>

# Debug output for variables
ansible all -m debug -a "var=hostvars"
ansible all -m debug -a "var=vars"
```

# Troubleshooting and Pitfalls

* Be aware of the current directory that you invoke any `ansible*` command in. Ansible is sensitive to certain files being in a the current directory, and this could many strange errors when outside of the proper working directory. When in doubt, run `cd /ansible_controller` to get back into the proper working directory.

# TODO

Actions and capabilities to add eventually:

- parameterize aur\_builder as handler and ensure user is removed after installation
- zsh/bash setup and default to zsh
- (neo)vim
- i3
- terminal
- blurlock (/usr/bin/blurlock) tweaked blur percentage
- automate browser addon installation: https://askubuntu.com/questions/73474/how-to-install-firefox-addon-from-command-line-in-scripts#73480

# References:

* [Ansible Debian Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)
* [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
* [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
