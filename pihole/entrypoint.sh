#!/usr/bin/env bash

# Start pihole DNS
sudo pihole-FTL

# Start pihole admin web GUI
sudo /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf -D
