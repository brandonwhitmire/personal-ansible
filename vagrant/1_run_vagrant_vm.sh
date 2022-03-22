#!/usr/bin/env bash

# This initial DNS request is done to get the Vagrant
# box past the NFS install and config portion... 
# where later the DNS issue gets fixed in resolv.conf
getent ahostsv4 mirror.csclub.uwaterloo.ca

vagrant up
