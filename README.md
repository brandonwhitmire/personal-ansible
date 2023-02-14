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

## Molecule

Molecule is an automated testing framework for Ansible, which includes validation, setting up infrastructure, and running plays.

```shell
# === PRE-REQUISITES ===

# Setup virtualenv with Molecule and its dependencies installed
python3 -m venv "$(git rev-parse --show-toplevel)/venv"
source venv/bin/activate
pip3 install --requirement "$(git rev-parse --show-toplevel)/requirements.txt"
ansible-galaxy collection install --requirements-file "$(git rev-parse --show-toplevel)/requirements.yml"

# === TEST ===

# END-to-END
# roughly: destroy -> create -> converge -> destroy
molecule test

# cleanup any leftover instances, artifacts, and temp dirs
molecule destroy && molecule reset

# same as 'test' but leaves the environment running
molecule converge

# basically: converge on a specific platform

molecule test --destroy never --platform-name arch-instance
molecule test --destroy never --platform-name kali-instance
```

## Molecule Errors

The simplest step is to use Ansible-like command options such as enabling debug and verbosity output when running the `molecule` command:

```shell
molecule --debug -vvvvv <SUBCOMMAND> ...
```

### Hierarchy of Abstraction Layers

Molecule has an incredible number of layers that can make things difficult to troubleshoot. This list might not include all that one would need to consider. Rough hierarchy of molecule layers from **high**- to **low**-level:

- Molecule
- Driver (e.g. Vagrant or Docker)
- Ansible
- SSH
- Python3
- OS-specific commands (e.g. package managers)

#### Vagrant-Specific (at the Driver layer)

Although Molecule can be good at outputting useful errors, sometimes vague errors regarding `ssh` are displayed without error output when internal VM commands are ran. In these cases, try reading all logs for the Driver (i.e. Vagrant in this case). There have been package manager issues that have caused these `ssh` "errors" that could only be discerned from reading the `vagrant.out` log (yes -- not the `vagrant.err` log as would be expected).

```shell
# Follow both Vagrant logs while VM provisions and builds
tail --follow ~/.cache/molecule/ansible/*/vagrant.{out,err}
```

```shell
# Follow Ansible logs while configuring
# NOTE: molecule.yml has this environment variable ANSIBLE_LOG_PATH,
# which places the Ansible log file in the below location
tail --follow /tmp/ansible.molecule.log
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

- fix `group_vars` duplication
- virtualization.yml (split off a VBOX or QEMU playbook)
- hook vagrant playbook to import only either Virtualbox or QEMU playbook (but have both in repo)
- arch linux general recommendations: https://wiki.archlinux.org/title/General_recommendations
- add keyboard shortcuts for Spanish chars
- fix i3status bar applets to show all
- create playbooks for:
  - Ansible (add `sshpass` as dependency)

- automate browser addon installation: https://askubuntu.com/questions/73474/how-to-install-firefox-addon-from-command-line-in-scripts#73480
- consider ricing Playbook XD

# References:

* [Ansible Debian Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)
* [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
* [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
