#!/bin/bash
# ==============================================================================
# PROBHARATH TECHNOLOGIES - SEAMLESS CLEAN INSTALLER
# Purges all residual instances and deploys a clean, isolated single instance.
# ==============================================================================

set -e
USER=$(whoami)
HOME_DIR="${HOME}"

GOLD='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GOLD}     PROBE TECH CONTROL - CLEAN SINGLE-INSTANCE DEPLOYMENT           ${NC}"
echo -e "${BLUE}=====================================================================${NC}"

# 1. STOP & PURGE ALL OLD OR DUPLICATE SERVICES
echo -e "${GOLD}[1/5] Purging old multi-instance services...${NC}"
sudo systemctl stop klipper* moonraker* probe-tech* nginx 2>/dev/null || true
sudo systemctl disable klipper* moonraker* probe-tech* 2>/dev/null || true

sudo rm -f /etc/systemd/system/klipper-*.service
sudo rm -f /etc/systemd/system/moonraker-*.service
sudo rm -f /etc/systemd/system/probe-tech-*.service
sudo rm -f /etc/systemd/system/probe-tech.service

# Remove batch folders if they exist
rm -rf "${HOME_DIR}/1_data" "${HOME_DIR}/2_data" "${HOME_DIR}/skip_data"
rm -rf "${HOME_DIR}/probe-tech-control-1" "${HOME_DIR}/probe-tech-control-2" "${HOME_DIR}/probe-tech-control-skip"

# 2. ENSURE STANDARD PRINTER_DATA DIRECTORY
echo -e "${GOLD}[2/5] Setting up ~/printer_data...${NC}"
mkdir -p "${HOME_DIR}/printer_data/config"
mkdir -p "${HOME_DIR}/printer_data/logs"
mkdir -p "${HOME_DIR}/printer_data/comms"
mkdir -p "${HOME_DIR}/printer_data/gcodes"
mkdir -p "${HOME_DIR}/printer_data/systemd"

# Copy or download probe_tech.cfg
if [ -f "${HOME_DIR}/ptc/probe_tech.cfg" ]; then
    cp "${HOME_DIR}/ptc/probe_tech.cfg" "${HOME_DIR}/printer_data/config/probe_tech.cfg"
fi

# Write boilerplate printer.cfg (with safe virtual demo MCU so UI never halts on boot)
cat << 'EOF' > "${HOME_DIR}/printer_data/config/printer.cfg"
[include probe_tech.cfg]

[mcu]
# Connect your printer board via USB, then update this path from /dev/serial/by-id/*
serial: /dev/null

[printer]
kinematics: none
max_velocity: 300
max_accel: 3000

[temperature_sensor Raspberry_Pi]
sensor_type: temperature_host
EOF

# Write standard single-instance moonraker.conf
cat << 'EOF' > "${HOME_DIR}/printer_data/config/moonraker.conf"
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: /home/probharath/printer_data/comms/klippy.sock

[authorization]
cors_domains:
    *
    *.lan
    *.local
trusted_clients:
    127.0.0.1
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    FE80::/10
    ::1/128

[octoprint_compat]

[history]

[file_manager]
enable_object_processing: True
EOF

# Fix username in configs if not probharath
sed -i "s|/home/probharath|${HOME_DIR}|g" "${HOME_DIR}/printer_data/config/moonraker.conf"

# 3. CONFIGURE SYSTEMD FOR KLIPPER & MOONRAKER
echo -e "${GOLD}[3/5] Standardizing Klipper and Moonraker services...${NC}"
cat << EOF | sudo tee /etc/systemd/system/klipper.service > /dev/null
[Unit]
Description=Klipper 3D Printer Firmware SV1
Documentation=https://www.klipper3d.org/
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=${USER}
RemainAfterExit=yes
WorkingDirectory=${HOME_DIR}/klipper
ExecStart=${HOME_DIR}/klippy-env/bin/python ${HOME_DIR}/klipper/klippy/klippy.py ${HOME_DIR}/printer_data/config/printer.cfg -I ${HOME_DIR}/printer_data/comms/klippy.serial -l ${HOME_DIR}/printer_data/logs/klippy.log -a ${HOME_DIR}/printer_data/comms/klippy.sock
Restart=always
RestartSec=5
EOF

cat << EOF | sudo tee /etc/systemd/system/moonraker.service > /dev/null
[Unit]
Description=Moonraker API Server
Documentation=https://moonraker.readthedocs.io/
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${HOME_DIR}/moonraker
ExecStart=${HOME_DIR}/moonraker-env/bin/python ${HOME_DIR}/moonraker/moonraker/moonraker.py -d ${HOME_DIR}/printer_data
Restart=always
RestartSec=5
EOF

# 4. DEPLOY PROBE TECH CONTROL WEB APP
echo -e "${GOLD}[4/5] Deploying Probe Tech Control Web Interface...${NC}"
rm -rf "${HOME_DIR}/probe-tech-control"
mkdir -p "${HOME_DIR}/probe-tech-control"

# Extract prebuilt bundle
if [ -f "${HOME_DIR}/ptc/probe-tech-control.zip" ]; then
    unzip -q -o "${HOME_DIR}/ptc/probe-tech-control.zip" -d "${HOME_DIR}/probe-tech-control/"
else
    curl -fsSL https://raw.githubusercontent.com/PravarHegde/probe-tech-control/develop/probe-tech-control.zip -o /tmp/ptc.zip
    unzip -q -o /tmp/ptc.zip -d "${HOME_DIR}/probe-tech-control/"
    rm -f /tmp/ptc.zip
fi

# Ensure config.json points to Moonraker port 7125
cat << 'EOF' > "${HOME_DIR}/probe-tech-control/config.json"
{
    "defaultLocale": "en",
    "defaultMode": "dark",
    "defaultTheme": "futuristic",
    "hostname": null,
    "port": 7125,
    "path": null,
    "instancesDB": "moonraker",
    "instances": []
}
EOF

# Add topbar front layer styling to CSS bundle
cat << 'EOF' >> "${HOME_DIR}/probe-tech-control/css/glassmorphism.css" 2>/dev/null || true
.v-app-bar.topbar {
  z-index: 9999 !important;
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
}
EOF

# Set permissions
chmod 755 "${HOME_DIR}"
chmod -R 755 "${HOME_DIR}/probe-tech-control"

# 5. CONFIGURE NGINX (PORT 8080)
echo -e "${GOLD}[5/5] Configuring high-performance Nginx web server...${NC}"
cat << EOF | sudo tee /etc/nginx/sites-available/default > /dev/null
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;

    root ${HOME_DIR}/probe-tech-control;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
}
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now klipper.service
sudo systemctl enable --now moonraker.service
sudo systemctl restart nginx

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GREEN}✓ PROBE TECH CONTROL CLEAN INSTALL COMPLETE!${NC}"
echo -e "${BLUE}=====================================================================${NC}"
echo -e "Web Interface: ${GREEN}http://$(hostname -I | awk '{print $1}'):8080${NC}"
echo -e "Moonraker API: ${GREEN}http://$(hostname -I | awk '{print $1}'):7125${NC}"
