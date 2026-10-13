#!/bin/bash
# ProBharath - Extra Automatic Smart WiFi Beacon
# Consumes 0 bytes of internet data.
# Sends a single lightweight 64-byte ping packet to the local gateway every 3 minutes
# to keep the local WiFi link, ARP cache, and router connection permanently active.

GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)
[ -z "$GATEWAY" ] && GATEWAY="192.168.1.1"

while true; do
    sleep 180
    ping -c 1 -W 1 "$GATEWAY" >/dev/null 2>&1
done
