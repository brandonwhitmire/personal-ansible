#!/bin/bash

# Simple script to get network IP address for polybar

FOUND=0
OUTPUT=""

# Check WiFi interfaces
for iface in /sys/class/net/w*; do
    [ ! -e "$iface" ] && continue
    ifname=${iface##*/}
    if ip link show "$ifname" 2>/dev/null | grep -q "state UP"; then
        IP=$(ip -4 addr show "$ifname" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
        if [ -n "$IP" ]; then
            SSID=$(iwgetid -r 2>/dev/null)
            if [ -n "$SSID" ]; then
                OUTPUT="📶 $SSID $IP"
            else
                OUTPUT="📶 $IP"
            fi
            FOUND=1
            break
        fi
    fi
done

# Check Ethernet interfaces
for iface in /sys/class/net/e*; do
    [ ! -e "$iface" ] && continue
    ifname=${iface##*/}
    if [ "$ifname" != "lo" ] && ip link show "$ifname" 2>/dev/null | grep -q "state UP"; then
        IP=$(ip -4 addr show "$ifname" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
        if [ -n "$IP" ]; then
            if [ -n "$OUTPUT" ]; then
                OUTPUT="$OUTPUT 🌐 $IP"
            else
                OUTPUT="🌐 $IP"
            fi
            FOUND=1
            break
        fi
    fi
done

# No connection
if [ "$FOUND" -eq 0 ]; then
    OUTPUT="❌ No connection"
fi

# Output for polybar (single echo with newline)
echo "$OUTPUT"
