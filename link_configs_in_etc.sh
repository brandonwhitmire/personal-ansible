#!/usr/bin/env bash


ETC_ANSIBLE="/etc/ansible"
CWD="$(pwd)"

sudo mkdir --parents "$ETC_ANSIBLE"

FILES=("ansible.cfg" "hosts" ".vault_pass")
for FILE in "${FILES[@]}" ; do
    sudo ln --force --symbolic --verbose "$CWD"/"$FILE" "$ETC_ANSIBLE"
done
