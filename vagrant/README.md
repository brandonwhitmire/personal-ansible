# Vagrant Setup

```shell
sudo pacman -S net-tools nfs-utils
sudo ufw allow out 53,113,123/udp
sudo pacman vagrant
sudo systemctl enable --now libvirtd
vagrant plugin install vagrant-libvirt
sudo usermod -aG libvirt $USER
```

# Troubleshooting

Sometimes domain resolving prevents the box from fully provisioning. Try resolving the name right before running a `vagrant up`.

```shell
# Resolve Manjaro box's repo
getent ahostsv4 mirror.csclub.uwaterloo.ca
```