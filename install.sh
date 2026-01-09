#!/bin/bash

# Probe Tech Control Installer

CONFIG_DIR="${HOME}/printer_data/config"
MOONRAKER_CONF="${CONFIG_DIR}/moonraker.conf"
PRINTER_CFG="${CONFIG_DIR}/printer.cfg"
PROBE_TECH_CFG="${CONFIG_DIR}/probe_tech.cfg"

echo "Installing Probe Tech Control Configuration..."

# 1. Copy probe_tech.cfg
if [ ! -f "$PROBE_TECH_CFG" ]; then
    echo "Copying probe_tech.cfg to $CONFIG_DIR..."
    cp probe_tech.cfg "$PROBE_TECH_CFG"
else
    echo "probe_tech.cfg already exists. Skipping copy."
fi

# 2. Update moonraker.conf
if grep -q "\[update_manager client probe_tech\]" "$MOONRAKER_CONF"; then
    echo "Moonraker already configured for Probe Tech."
else
    echo "Configuring Moonraker Update Manager..."
    # Remove old mainsail config if easy to find (simple sed might be risky, appending is safer)
    cat <<EOF >> "$MOONRAKER_CONF"

[update_manager client probe_tech]
type: web
channel: stable
repo: PravarHegde/probe-tech-control
path: ~/probe-tech-control
EOF
fi

# 3. Include in printer.cfg
if grep -q "include probe_tech.cfg" "$PRINTER_CFG"; then
    echo "printer.cfg already includes probe_tech.cfg."
else
    echo "Adding include to printer.cfg..."
    # Add to the top of the file
    sed -i '1s/^/[include probe_tech.cfg]\n/' "$PRINTER_CFG"
fi

echo "Installation complete! Please restart Moonraker and Klipper."
