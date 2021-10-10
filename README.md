# Ansible

Ansible playbooks for various setups and configurations

---

# Pre-requisites
- `sshd` running (and allowed through firewall)
```shell
sudo systemctl start sshd
```
- If using SSH key authentication, then add the pubkey to `~/.ssh/authorized_keys`:
```shell
ssh-copy-id -i ~/.ssh/id_rsa <USER>@<IP_ADDR>
```
[SSH Auth via Keys](https://www.ssh.com/academy/ssh/copy-id)
---

```shell
# Show inventory
ansible-inventory --list

# Configure VMs by running playbooks against VMs as returned from ansible-inventory
# NOTE: <PLAYBOOK> is any of the *.yml* files in this repo root directory
ansible-playbook <PLAYBOOK>

# Specify hosts manually instead of using inventory.vmware.yml
# NOTE: when not providing a file to "-i" the trailing ',' is required for a hostname or IP address
ANSIBLE_INVENTORY_ENABLED="host_list" ansible-playbook --ask-become-pass --inventory <IP_ADDR>, --user <USER> <PLAYBOOK>
```

---

# References:
* [Ansible Debian Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)
* [Ansible Commands](https://docs.ansible.com/ansible/latest/collections/ansible/index.html)
* [Ansible Playbook Examples](https://github.com/ansible/ansible-examples)
