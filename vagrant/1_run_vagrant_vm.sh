#!/usr/bin/env bash

getent ahostsv4 mirror.csclub.uwaterloo.ca
getent ahostsv4 repo.ialab.dsu.edu
vagrant up --provision
