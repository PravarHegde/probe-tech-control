#!/usr/bin/env python3
"""
==============================================================================
PROBHARATH MACHINE OS - HARDWARE PROVISIONER & ZERO-CONFIG DAEMON
==============================================================================
Handles:
1. Boot-time pre-seeded network configuration from bootfs/probharath_setup.json
2. 22-second connectivity check with prioritized auto-failover
3. Automated fallback to Open WiFi Hotspot & Bluetooth BLE Beacon on failure
4. ProConnect Cloud auto-claiming
==============================================================================
"""

import os
import sys
import time
import json
import socket
import subprocess
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)
logger = logging.getLogger("ProBharathProvisioner")

BOOT_PATHS = [
    "/boot/firmware/probharath_setup.json",
    "/boot/probharath_setup.json",
    os.path.expanduser("~/probharath_setup.json")
]
RELAY_CONFIG_PATH = os.path.expanduser("~/printer_data/config/proconnect_relay.json")
CLAIM_CODE_PATH = os.path.expanduser("~/printer_data/config/claim_code.txt")

def run_cmd(cmd, check=False):
    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
        return res.stdout.strip()
    except Exception as e:
        logger.error(f"Command failed '{cmd}': {e}")
        return ""

def get_mac_suffix():
    try:
        out = run_cmd("cat /sys/class/net/wlan0/address")
        if out:
            return out.replace(":", "")[-4:].upper()
    except Exception:
        pass
    return "Node"

def is_online():
    # Check if wlan0 or eth0 has an active IPv4 address and can resolve DNS
    try:
        socket.setdefaulttimeout(2.0)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect(("1.1.1.1", 53))
        return True
    except Exception:
        return False

def setup_networks_from_json(config_data):
    logger.info("Applying pre-seeded network configurations...")
    networks = config_data.get("networks", [])
    
    for net in networks:
        ssid = net.get("ssid")
        pwd = net.get("password", "")
        priority = net.get("priority", 10)
        
        if not ssid:
            continue
            
        logger.info(f"Configuring WiFi '{ssid}' with priority {priority}...")
        # Remove existing connection with same name to avoid duplicates
        run_cmd(f"nmcli connection delete '{ssid}' 2>/dev/null")
        
        if pwd:
            cmd = f"nmcli connection add type wifi con-name '{ssid}' ifname wlan0 ssid '{ssid}' -- wifi-sec.key-mgmt wpa-psk wifi-sec.psk '{pwd}' connection.autoconnect-priority {priority}"
        else:
            cmd = f"nmcli connection add type wifi con-name '{ssid}' ifname wlan0 ssid '{ssid}' connection.autoconnect-priority {priority}"
            
        run_cmd(cmd)

    claim_code = config_data.get("claim_code")
    if claim_code:
        logger.info(f"Seeding Cloud Claim Code: {claim_code}")
        os.makedirs(os.path.dirname(CLAIM_CODE_PATH), exist_ok=True)
        with open(CLAIM_CODE_PATH, "w") as f:
            f.write(claim_code.strip() + "\n")

def start_fallback_hotspot():
    mac_suffix = get_mac_suffix()
    hotspot_ssid = f"ProBharath-Setup-{mac_suffix}"
    logger.warning(f"No reachable WiFi detected. Starting Setup Hotspot: '{hotspot_ssid}'...")
    
    # Clean up any existing hotspot
    run_cmd("nmcli connection delete 'ProBharath-Hotspot' 2>/dev/null")
    
    # Create open hotspot on wlan0
    cmd = (
        f"nmcli connection add type wifi ifname wlan0 con-name 'ProBharath-Hotspot' "
        f"autoconnect no ssid '{hotspot_ssid}' 802-11-wireless.mode ap 802-11-wireless.band bg "
        f"ipv4.method shared ipv4.addresses 192.168.4.1/24"
    )
    run_cmd(cmd)
    run_cmd("nmcli connection up 'ProBharath-Hotspot'")
    logger.info("✓ Setup Hotspot activated at 192.168.4.1")

def start_ble_beacon():
    mac_suffix = get_mac_suffix()
    ble_name = f"ProBharath-{mac_suffix}"
    logger.info(f"Broadcasting Bluetooth BLE Beacon: '{ble_name}'...")
    try:
        run_cmd("hciconfig hci0 up 2>/dev/null")
        run_cmd(f"bluetoothctl system-alias '{ble_name}' 2>/dev/null")
        run_cmd("bluetoothctl discoverable on 2>/dev/null")
    except Exception as e:
        logger.error(f"BLE Beacon failed: {e}")

def main():
    logger.info("Initializing ProBharath Provisioner Daemon...")
    
    # Step 1: Check for bootfs setup file
    for path in BOOT_PATHS:
        if os.path.exists(path):
            logger.info(f"Found setup payload at {path}")
            try:
                with open(path, "r") as f:
                    config = json.load(f)
                setup_networks_from_json(config)
                # Rename file to mark as processed
                os.rename(path, path + ".processed")
                logger.info(f"Renamed {path} to prevent duplicate runs.")
                break
            except Exception as e:
                logger.error(f"Failed to process {path}: {e}")

    # Step 2: 22-Second Connectivity Wait
    logger.info("Waiting up to 22 seconds for WiFi DHCP handshake...")
    start_time = time.time()
    connected = False
    
    while time.time() - start_time < 22:
        if is_online():
            connected = True
            logger.info("✓ Primary WiFi connection verified and internet reachable!")
            break
        time.sleep(2)

    # Step 3: Fallback if offline
    if not connected:
        start_fallback_hotspot()
        start_ble_beacon()
    else:
        logger.info("System is online. Hotspot and BLE beacons remain idle.")

if __name__ == "__main__":
    main()
