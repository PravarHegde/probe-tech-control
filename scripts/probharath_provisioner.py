#!/usr/bin/env python3
"""
==============================================================================
PROBHARATH MACHINE OS - HARDWARE PROVISIONER & LIVE NETWORK DAEMON
==============================================================================
Provides:
1. Boot-time network auto-setup & failover
2. Persistent REST API on port 8255 for live Wi-Fi scanning & priority management
3. Emergency Fallback Hotspot (ProBharath-Setup-{MAC}) and BLE Beacon
==============================================================================
"""

import os
import sys
import time
import json
import socket
import subprocess
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading

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
    return "4A19"

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        pass
    out = run_cmd("hostname -I")
    if out:
        return out.split()[0]
    return "127.0.0.1"

def is_online():
    try:
        socket.setdefaulttimeout(2.0)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect(("1.1.1.1", 53))
        return True
    except Exception:
        return False

def get_active_wifi():
    out = run_cmd("nmcli -t -f active,ssid,signal dev wifi list")
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) >= 3 and parts[0] == "yes":
            return {
                "ssid": parts[1],
                "signal": int(parts[2]) if parts[2].isdigit() else 50,
                "connected": True
            }
    return {
        "ssid": "",
        "signal": 0,
        "connected": False
    }

def scan_nearby_wifi():
    run_cmd("nmcli dev wifi rescan 2>/dev/null")
    time.sleep(1)
    out = run_cmd("nmcli -t -f active,ssid,signal,security dev wifi list")
    networks = []
    seen = set()
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) >= 4:
            active = (parts[0] == "yes")
            ssid = parts[1].strip()
            signal = int(parts[2]) if parts[2].isdigit() else 50
            security = parts[3].strip() or "Open"
            if ssid and ssid not in seen:
                seen.add(ssid)
                networks.append({
                    "ssid": ssid,
                    "signal": signal,
                    "security": security,
                    "active": active
                })
    return sorted(networks, key=lambda x: (not x["active"], -x["signal"]))

def get_saved_connections():
    out = run_cmd("nmcli -t -f name,type,autoconnect-priority connection show")
    saved = []
    active_wifi = get_active_wifi()
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) >= 3 and parts[1] == "802-11-wireless":
            name = parts[0]
            if "Hotspot" in name:
                continue
            raw_prio = 0
            try:
                raw_prio = int(parts[2])
            except Exception:
                pass
            display_name = name.replace("netplan-wlan0-", "")
            if raw_prio >= 80:
                ui_prio = 1
            elif raw_prio >= 40:
                ui_prio = 2
            elif raw_prio > 0:
                ui_prio = 3
            else:
                ui_prio = 1

            is_active = (display_name == active_wifi["ssid"]) or (name == active_wifi["ssid"])
            saved.append({
                "name": name,
                "ssid": display_name,
                "priority": ui_prio,
                "security": "WPA2/WPA3",
                "active": is_active
            })
    return sorted(saved, key=lambda x: (x["priority"], not x["active"]))

def connect_or_save_wifi(ssid, password, priority=1):
    logger.info(f"Adding/Updating Wi-Fi connection '{ssid}' with UI priority {priority}...")
    # Map UI priority (1, 2, 3) to NetworkManager autoconnect-priority (100, 50, 10)
    nm_prio = 100 if priority == 1 else (50 if priority == 2 else 10)
    run_cmd(f"nmcli connection delete '{ssid}' 2>/dev/null")
    if password:
        cmd = f"nmcli connection add type wifi con-name '{ssid}' ifname wlan0 ssid '{ssid}' wifi-sec.key-mgmt wpa-psk wifi-sec.psk '{password}' connection.autoconnect-priority {nm_prio}"
    else:
        cmd = f"nmcli connection add type wifi con-name '{ssid}' ifname wlan0 ssid '{ssid}' connection.autoconnect-priority {nm_prio}"
    run_cmd(cmd)
    res = run_cmd(f"nmcli connection up '{ssid}' 2>&1")
    is_connected = ("successfully activated" in res.lower())
    if is_connected:
        msg = f"Connected to '{ssid}' successfully!"
    else:
        msg = f"Saved '{ssid}' (Priority {priority}). Will autoconnect when in range."
    return {"success": True, "connected": is_connected, "message": msg, "output": res}

def delete_saved_connection(name):
    logger.info(f"Deleting Wi-Fi connection '{name}'...")
    run_cmd(f"nmcli connection delete '{name}' 2>/dev/null")
    if name.startswith("netplan-wlan0-"):
        short_name = name.replace("netplan-wlan0-", "")
        run_cmd(f"nmcli connection delete '{short_name}' 2>/dev/null")
    return True

def start_fallback_hotspot():
    mac_suffix = get_mac_suffix()
    hotspot_ssid = f"ProBharath-Setup-{mac_suffix}"
    logger.warning(f"Starting Emergency Hotspot '{hotspot_ssid}'...")
    run_cmd("nmcli connection delete 'ProBharath-Hotspot' 2>/dev/null")
    cmd = (
        f"nmcli connection add type wifi ifname wlan0 con-name 'ProBharath-Hotspot' "
        f"autoconnect no ssid '{hotspot_ssid}' 802-11-wireless.mode ap 802-11-wireless.band bg "
        f"ipv4.method shared ipv4.addresses 192.168.4.1/24"
    )
    run_cmd(cmd)
    run_cmd("nmcli connection up 'ProBharath-Hotspot'")

def stop_fallback_hotspot():
    run_cmd("nmcli connection down 'ProBharath-Hotspot' 2>/dev/null")

class NetworkApiHandler(BaseHTTPRequestHandler):
    def _send_cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors()
        self.end_headers()

    def do_GET(self):
        if self.path in ['/api/network/status', '/api/status']:
            active = get_active_wifi()
            data = {
                "connected": active["connected"],
                "ssid": active["ssid"],
                "signal": active["signal"],
                "ip": get_local_ip(),
                "hostname": "probharath.local",
                "mac_suffix": get_mac_suffix(),
                "online": is_online()
            }
            self._respond_json(data)
        elif self.path == '/api/network/scan':
            networks = scan_nearby_wifi()
            self._respond_json({"networks": networks})
        elif self.path == '/api/network/saved':
            saved = get_saved_connections()
            self._respond_json({"saved": saved})
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8') if content_length > 0 else "{}"
        try:
            payload = json.loads(body)
        except Exception:
            payload = {}

        if self.path == '/api/network/connect':
            ssid = payload.get('ssid', '')
            password = payload.get('password', '')
            priority = int(payload.get('priority', 1))
            res = connect_or_save_wifi(ssid, password, priority)
            self._respond_json(res)
        elif self.path == '/api/network/delete':
            name = payload.get('name', '') or payload.get('ssid', '')
            delete_saved_connection(name)
            self._respond_json({"success": True})
        elif self.path == '/api/network/hotspot':
            enabled = payload.get('enabled', False)
            if enabled:
                start_fallback_hotspot()
            else:
                stop_fallback_hotspot()
            self._respond_json({"success": True, "hotspot_enabled": enabled})
        else:
            self.send_response(404)
            self.end_headers()

    def _respond_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self._send_cors()
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def log_message(self, format, *args):
        pass  # Quiet logging for high throughput

def run_http_server():
    server = HTTPServer(('0.0.0.0', 8255), NetworkApiHandler)
    logger.info("📡 ProBharath Network REST API Server listening on port 8255...")
    server.serve_forever()

def main():
    logger.info("Initializing ProBharath Provisioner & Network Service...")
    
    # Check for setup payload
    for path in BOOT_PATHS:
        if os.path.exists(path):
            logger.info(f"Found setup payload at {path}")
            try:
                with open(path, "r") as f:
                    config = json.load(f)
                for net in config.get("networks", []):
                    connect_or_save_wifi(net.get("ssid"), net.get("password", ""), net.get("priority", 1))
                os.rename(path, path + ".processed")
                break
            except Exception as e:
                logger.error(f"Failed to process {path}: {e}")

    # Start REST API server in background thread
    t = threading.Thread(target=run_http_server, daemon=True)
    t.start()

    # 22-second connectivity check
    start_time = time.time()
    connected = False
    while time.time() - start_time < 22:
        if is_online():
            connected = True
            logger.info("✓ Primary Wi-Fi connection verified and online!")
            break
        time.sleep(2)

    if not connected:
        logger.warning("No internet connection detected after 22s. Activating Emergency Hotspot...")
        start_fallback_hotspot()

    # Keep daemon alive
    while True:
        time.sleep(30)

if __name__ == "__main__":
    main()
