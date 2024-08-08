# Ansible

Ansible playbooks for various setups and configurations.

**NOTE: these playbooks are tailored to _Arch Linux_, which uses the `pacman` package manager and related utilities**

# Pre-requisites

## Controller

To use the controller, simply enter in a Python virtual environment with all dependencies installed. This is the machine that will initiate connections and configure the target nodes:

```bash
# REQUIRED: for SSH password access
sudo pacman -S --noconfirm sshpass

python3 -m venv "$(git rev-parse --show-toplevel)/venv"
source venv/bin/activate

# Install Python and Ansible Galaxy libraries
pip3 install --requirement "$(git rev-parse --show-toplevel)/requirements.txt"
ansible-galaxy collection install --requirements-file "$(git rev-parse --show-toplevel)/requirements.yml"

# First time setup: automated prompting for Ansible config files
./1_run_first_time_setup.py
```

## Targets

This is the machine or machines that will be configured via the controller.

- REQUIRED: `sshd` running (and allowed through firewall) on target nodes:

```bash
sudo systemctl enable --now sshd
```

- If using SSH key authentication, then add the pubkey to `~/.ssh/authorized_keys`:

```bash
ssh-copy-id -i ~/.ssh/id_rsa <USER>@<IP_ADDR>
```

# Quick Start

Using the controller to configure target nodes:

```bash
# Activate Python venv (assuming pre-reqs from above are met)
source venv/bin/activate

ansible-playbook playbooks/main.yml
```

# Common Commands

```bash
# Show inventory
ansible-inventory --list
ansible-inventory --graph

# Debug mode (this will not perform the actions but emulate as if they were)
ansible-playbook --check -vvvvv <PLAYBOOK>

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
    --become \
    --args 'reboot now' \
    all  # "all" is a necessary host(s) pattern that is all-inclusive
```

# Testing and Validation

A combination of different levels to test an Ansible project:

```shell
yamllint
ansible-playbook --syntax-check
ansible-lint
molecule test # integration
ansible-playbook --check  # against target
Parallel Infrastructure # RARE
```

- References: https://youtu.be/FaXVZ60o8L8?t=1239

## Molecule

Molecule is an automated testing framework for Ansible, which includes validation, setting up infrastructure, and running plays.

```shell
# cleanup any leftover instances, artifacts, and temp dirs
molecule destroy && molecule reset

# same as 'test' but leaves the environment running
# to test new changes or additions
molecule converge

# END-to-END: converge on a specific platform
molecule test --destroy never --platform-name arch-instance
```

## Molecule Errors

The simplest step is to use Ansible-like command options such as enabling debug and verbosity output when running the `molecule` command:

```shell
molecule --debug -vvvvv <SUBCOMMAND>
```

### Hierarchy of Abstraction Layers

Molecule has an incredible number of layers that can make things difficult to troubleshoot. This list might not include all that one would need to consider. Rough hierarchy of molecule layers from **high**- to **low**-level:

- Molecule
- Driver (e.g. Vagrant or Docker)
- Ansible
- SSH
- Python3
- OS-local commands

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

# References:

* [Ansible Debian Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)
* [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
* [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
