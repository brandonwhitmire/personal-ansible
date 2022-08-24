# Ansible

Ansible playbooks for various setups and configurations.

**Currently, these playbooks are tailored to _Arch Linux_, which uses the `pacman` package manager and related utilities.**

# Pre-requisites

## Controller

This is the machine that will initiate connections and configure the target nodes.

- REQUIRED: `docker`:

```bash
# For Arch-based systems
sudo pacman -S --noconfirm docker
sudo systemctl enable --now docker
sudo usermod --append --groups docker "$USER" # requires logout/reboot
```

Run the controller like so:

```bash
./1_run_ansible_controller.sh
```

## Targets

This is the machine or machines that will be configured via the controller.

- REQUIRED: `sshd` running (and allowed through firewall) on target nodes:

```bash
sudo systemctl start sshd # SSH on until reboot
sudo systemctl enable --now sshd # SSH permanently on
```

- If using SSH key authentication, then add the pubkey to `~/.ssh/authorized_keys`:

> [SSH Auth via Keys](https://www.ssh.com/academy/ssh/copy-id)

```bash
ssh-copy-id -i ~/.ssh/id_rsa <USER>@<IP_ADDR>
```

### Playbook Precedence

Most playbooks are written such that they are indepedent from each other and should not require anything installed beforehand (other than what is mentioned above). However, this assumption only follows if the playbook `1_install_baseline_packages.yml` has been previously ran. This will install numerous packages, but especially those that are required for the remaining playbooks.

> e.g. #1: The `python-pip` OS-level package is required to install Python3 modules, but this package is not included in all playbooks that install Python3 modules since this would add an undue burden to all current and future playbooks.

> e.g. #2: The `unzip` is included in the Calibre playbook since that package is specifically required to run the Ansible `unarchive` module, which is only used in that respective playbook... the `unzip` package would get moved into `1_install_baseline_packages.yml` if its usage becomes more prevalent in more than one or so playbooks.

# Quick Start

Using the Dockerized Ansible controller to configure target nodes:

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

# Debug mode (this will not perform the actions but emulate as if they were)
ansible-playbook --check -vvv <PLAYBOOK>

# Debug output for variables
ansible all -m debug -a "var=hostvars"
ansible all -m debug -a "var=vars"

# Probe a particular variable, in this case "ansible_user"
ansible -m debug -a 'msg={{ ansible_user }}' all

# Specify hosts manually instead of using an inventory file
# NOTE: when not providing a file to "-i" the trailing ',' is required for the hostname or IP address
ANSIBLE_PIPELINING=true \
ANSIBLE_INVENTORY_ENABLED="host_list" ansible-playbook \
    --inventory <HOST>, \
    --extra-vars "ansible_ssh_extra_args='-o StrictHostKeyChecking=no' ansible_user=<USER> ansible_ssh_password=<PASSWORD> ansible_ssh_become_password=<PASSWORD>" \
    <PLAYBOOKS>
```


## Ad-Hoc Commands

Ad-hoc commands are just that -- running commands on valid hosts without needing a task, playbook, role, etc.

```shell
# Reboot remote host with escalation ("--become" is like "sudo")
ANSIBLE_INVENTORY_ENABLED="host_list" \
ansible \
    --inventory <HOST>, \
    --extra-vars "ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=1200' ansible_user=<USER> ansible_ssh_password=<PASSWORD> ansible_ssh_become_password=<PASSWORD>" \
    --args 'reboot now' \
    --become \
    all 
# "all" is a necessary host(s) pattern that is all-inclusive
```

# Testing and Validation

References:
- https://youtu.be/FaXVZ60o8L8?t=1239

```shell
yamllint
ansible-playbook --syntax-check
ansible-lint
molecule test # integration
ansible-playbook --check # against target
Parallel Infrastructure # RARE
```

# Troubleshooting and Pitfalls

* Be aware of the current directory that invokes any `ansible*` command. Ansible is sensitive to certain files being in the current directory, and this could cause many strange errors when outside of the proper working directory. When in doubt, run "`cd /ansible_controller`" to get back into the proper working directory or exit the Dockerized Ansible controller node then re-enter it via "`./1_run_ansible_controller.sh`".

* Run interactive debugger upon task fail:

```shell
# append env variable to command or export
ANSIBLE_ENABLE_TASK_DEBUGGER=True
```

# Things to Backup

This repository was written with the goal of getting a fresh installation to a personalized, standard state. For clarity's sake, the following is a rough list of things that should be backed up (usually with `borg`) but will not be added into this repository:

- Web browser bookmarks
- Password database
- EBook collection
- Music/Audiobook Collection
- SSH keys

# TODO

Actions and capabilities to add eventually:

- arch linux general recommendations: https://wiki.archlinux.org/title/General_recommendations
- add keyboard shortcuts for Spanish chars
- fix i3status bar applets to show all
- create playbooks for:
  - Ansible
  - Virtualbox
- hook vagrant playbook to import only either Virtualbox or QEMU playbook (but have both in repo)
- consider migrating requirements_ansible.txt into Dockerfile
- automate browser addon installation: https://askubuntu.com/questions/73474/how-to-install-firefox-addon-from-command-line-in-scripts#73480
- consider ricing Playbook XD

# References:

* [Ansible Debian Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)
* [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
* [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
