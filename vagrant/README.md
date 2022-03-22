# Vagrant Setup

The following command might be needed to allow Vagrant to work, depending on the setup.

```bash
sudo pacman -S net-tools nfs-utils vagrant
sudo systemctl enable --now libvirtd
vagrant plugin install vagrant-libvirt
sudo usermod -aG libvirt $USER
sudo ufw allow out 53,113,123/udp
```

## Hosts File

To connect to the Vagrant machine via Ansible, the following line in the `hosts` or inventory file will need to be added:

```bash
# Local IP address:	ip addr
# Forwarded port:	vagrant ssh-config
# NOTE: Vagrant user creds are almost always `vagrant` // `vagrant`
<LOCAL_IP>:<FORWARDED_PORT> ansible_user=vagrant ansible_ssh_password=vagrant ansible_ssh_become_password=vagrant

# Real Example
192.168.5.130:2222 ansible_user=vagrant ansible_ssh_password=vagrant ansible_ssh_become_password=vagrant
```

# Quickstart

Vagrant commands should be ran from the vagrant directory.

```bash
cd vagrant/

# Run helper script
./1_run_vagrant_vm.sh
```

## Clean Environment

Delete and re-build environment to a fresh, unconfigured state.

```bash
vagrant halt -f && vagrant destroy -f
```

# Troubleshooting

Sometimes domain resolving prevents the box from fully provisioning. Try resolving the name right before running a `vagrant up`.

```shell
# Resolve Manjaro box's repo
getent ahostsv4 mirror.csclub.uwaterloo.ca
```
