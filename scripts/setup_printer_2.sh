#!/bin/bash
# Setup Printer 2 Manually

USER=$(whoami)
HOME_DIR="/home/$USER"
INST_NAME="printer_2"
INST_DIR="$HOME_DIR/${INST_NAME}_data"
CONF_DIR="$INST_DIR/config"
LOG_DIR="$INST_DIR/logs"
GCODE_DIR="$INST_DIR/gcodes"
SYS_DIR="$INST_DIR/systemd"
COMMS_DIR="$INST_DIR/comms"
WEB_DIR="$HOME_DIR/probe-tech-control-${INST_NAME}"

# 1. Create Directories
echo "Creating directories..."
mkdir -p "$CONF_DIR" "$LOG_DIR" "$GCODE_DIR" "$SYS_DIR" "$COMMS_DIR"

# 2. Configs
echo "Creating configs..."
if [ ! -f "$CONF_DIR/printer.cfg" ]; then
    cat <<EOF > "$CONF_DIR/printer.cfg"
[include probe_tech.cfg]
[mcu]
serial: /dev/serial/by-id/CHANGE_ME_TO_YOUR_ID

[printer]
kinematics: none
max_velocity: 300
max_accel: 3000
EOF
fi

if [ ! -f "$CONF_DIR/probe_tech.cfg" ]; then
    cp "$HOME_DIR/ptc/probe_tech.cfg" "$CONF_DIR/probe_tech.cfg"
    # Patch path
    sed -i "s|path: ~/printer_data/gcodes|path: ${INST_DIR}/gcodes|" "$CONF_DIR/probe_tech.cfg"
fi

if [ ! -f "$CONF_DIR/moonraker.conf" ]; then
    cat <<EOF > "$CONF_DIR/moonraker.conf"
[server]
host: 0.0.0.0
port: 7126
klippy_uds_address: ${COMMS_DIR}/klippy.sock

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

[update_manager probe_tech]
type: git_repo
path: ~/${WEB_DIR##$HOME/}
origin: https://github.com/PravarHegde/probe-tech-control.git
primary_branch: develop
is_system_service: False
EOF
fi

# 3. Environment Files
echo "Creating env files..."
cat <<EOF > "${SYS_DIR}/klipper.env"
KLIPPER_ARGS="${HOME_DIR}/klipper/klippy/klippy.py ${CONF_DIR}/printer.cfg -I ${COMMS_DIR}/klippy.serial -l ${LOG_DIR}/klippy.log -a ${COMMS_DIR}/klippy.sock"
EOF

cat <<EOF > "${SYS_DIR}/moonraker.env"
MOONRAKER_ARGS="${HOME_DIR}/moonraker/moonraker/moonraker.py -d ${INST_DIR}"
EOF

# 4. Web Interface
echo "Deploying Web Interface..."
mkdir -p "$WEB_DIR"
cp -r "$HOME_DIR/ptc/probe-tech-control.zip" "$WEB_DIR/"
unzip -o -q "$WEB_DIR/probe-tech-control.zip" -d "$WEB_DIR"
cp "$HOME_DIR/ptc/spa_server.py" "$WEB_DIR/"

# 5. Service Files
echo "Creating services..."

# Klipper Service
cat <<EOF | sudo tee /etc/systemd/system/klipper-${INST_NAME}.service
[Unit]
Description=Klipper for ${INST_NAME}
Before=moonraker-${INST_NAME}.service
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=${USER}
RemainAfterExit=yes
WorkingDirectory=${HOME_DIR}/klipper
EnvironmentFile=${SYS_DIR}/klipper.env
ExecStart=${HOME_DIR}/klippy-env/bin/python \$KLIPPER_ARGS
Restart=always
RestartSec=10
EOF

# Moonraker Service
cat <<EOF | sudo tee /etc/systemd/system/moonraker-${INST_NAME}.service
[Unit]
Description=Moonraker for ${INST_NAME}
Requires=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=${USER}
SupplementaryGroups=moonraker-admin
RemainAfterExit=yes
WorkingDirectory=${HOME_DIR}/moonraker
EnvironmentFile=${SYS_DIR}/moonraker.env
ExecStart=${HOME_DIR}/moonraker-env/bin/python \$MOONRAKER_ARGS
Restart=always
RestartSec=10
EOF

# Web Service (Find open port strategy: try 8081)
# Simply hardcoding 8081 for this manual script as requested "one more"
WEB_PORT=8081

cat <<EOF | sudo tee /etc/systemd/system/probe-tech-${INST_NAME}.service
[Unit]
Description=PTC Web Interface (${INST_NAME})
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${WEB_DIR}
ExecStart=/usr/bin/python3 spa_server.py --port ${WEB_PORT} --dir ${WEB_DIR}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 6. Enable and Start
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable klipper-${INST_NAME} moonraker-${INST_NAME} probe-tech-${INST_NAME}
sudo systemctl start klipper-${INST_NAME} moonraker-${INST_NAME} probe-tech-${INST_NAME}

echo "Done! Access at http://$(hostname -I | awk '{print $1}'):${WEB_PORT}"
