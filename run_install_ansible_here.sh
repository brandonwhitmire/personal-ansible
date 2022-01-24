#!/usr/bin/env bash

set -u
set -e

pip3 install --upgrade --user pip setuptools 
pip3 install --upgrade --user ansible
pip3 install --upgrade --user --requirement ../requirements.txt

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' | tee -a ~/.bashrc ~/.zshrc
fi

ansible-galaxy collection install -fvvvv community.vmware
