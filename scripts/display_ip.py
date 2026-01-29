#!/usr/bin/env python3
import socket
import sys
import os
import time
import json

# Path to Klipper socket
# Try to find it or use argument
UDS_PATH = os.path.expanduser("~/printer_data/comms/klippy.sock")

def get_ip():
    try:
        # Connect to a public DNS server to determine the most appropriate network interface specific IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        # Fallback
        hostname_output = os.popen("hostname -I").read().strip().split(" ")[0]
        return hostname_output

def send_gcode(gcode):
    if not os.path.exists(UDS_PATH):
        print(f"Error: Socket {UDS_PATH} does not exist.")
        return

    try:
        # Create UDS socket
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(UDS_PATH)
        
        # Klipper protocol is JSON-RPC-like lines or direct commands?
        # Actually, for the API socket, it expects JSON-RPC.
        # But we can just use the "gcode" endpoint.
        
        rpc_cmd = {
            "id": 123,
            "method": "printer.gcode.script",
            "params": {"script": gcode}
        }
        
        msg = json.dumps(rpc_cmd) + "\n"
        # Terminate with a specific separator if needed, but usually newline is fine for JSON objects
        # Wait, Klipper socket uses a specific framing sometimes? 
        # No, standard Moonraker connects to it. It expects JSON blocks separated by \x03 (ETX) sometimes?
        # Let's check common implementation.
        # Actually simpler: writing to /tmp/printer (pseudo-tty) if enabled.
        # But let's stick to the JSON-RPC over socket which allows sending gcode.
        
        sock.sendall(msg.encode('utf-8'))
        
        # Read response (optional)
        data = sock.recv(4096)
        # print("Received:", data.decode())
        
        sock.close()
    except Exception as e:
        print(f"Failed to send G-code: {e}")

if __name__ == "__main__":
    time.sleep(2) # Wait a bit for network
    ip = get_ip()
    print(f"Detected IP: {ip}")
    if ip:
        # Send M117
        cmd = f"M117 IP: {ip}"
        send_gcode(cmd)
        
        # Also try to log it to console
        send_gcode(f"M118 Network IP: {ip}")
