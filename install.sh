#!/bin/bash

# Probe Tech Control Installer
# A simple interactive installer similar to KIAUH

# Auto-detect configuration directory
CONFIG_DIR=""
POSSIBLE_DIRS=(
  "${HOME}/printer_data/config"
  "${HOME}/printer_c_data/config"
  "${HOME}/klipper_config"
)

for dir in "${POSSIBLE_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    CONFIG_DIR="$dir"
    break
  fi
done

# We proceed even if no config dir found yet (Klipper setup might create it)
if [ -z "$CONFIG_DIR" ]; then
    # Default to printer_data if not found (standard Klipper default)
    CONFIG_DIR="${HOME}/printer_data/config"
fi

MOONRAKER_CONF="${CONFIG_DIR}/moonraker.conf"
PRINTER_CFG="${CONFIG_DIR}/printer.cfg"
PROBE_TECH_CFG="${CONFIG_DIR}/probe_tech.cfg"
SERVICE_FILE="/etc/systemd/system/probe-tech.service"
CURRENT_USER=$(whoami)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- HELPER FUNCTIONS ---

print_header() {
    clear
    echo -e "${CYAN}=================================================${NC}"
    echo -e "${CYAN}           PROBE TECH CONTROL INSTALLER          ${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo -e "Config Dir: ${CYAN}${CONFIG_DIR}${NC}"
    echo ""
}

check_status() {
    # Check Probe Tech Config
    if [ -f "$PROBE_TECH_CFG" ]; then
        echo -e "Interface Config: ${GREEN}Installed${NC}"
    else
        echo -e "Interface Config: ${RED}Not Installed${NC}"
    fi

    # Check Service
    if systemctl is-active --quiet probe-tech; then
        echo -e "Interface Server: ${GREEN}Running${NC}"
    else
        echo -e "Interface Server: ${RED}Stopped${NC}"
    fi

    # Check Moonraker
    if [ -d "${HOME}/moonraker" ]; then
        echo -e "Moonraker:        ${GREEN}Installed${NC}"
    else
        echo -e "Moonraker:        ${RED}Not Installed${NC}"
    fi

    # Check Klipper
    if [ -d "${HOME}/klipper" ]; then
        echo -e "Klipper:          ${GREEN}Installed${NC}"
    else
        echo -e "Klipper:          ${RED}Not Installed${NC}"
    fi

    echo ""
}

# --- INSTALLATION MODULES ---

install_klipper() {
    echo -e "${YELLOW}Installing Klipper...${NC}"
    if [ -d "${HOME}/klipper" ]; then
        echo -e "${GREEN}Klipper is already installed.${NC}"
    else
        echo "Cloning Klipper repository..."
        cd "${HOME}"
        git clone https://github.com/Klipper3d/klipper.git
        echo "Running Klipper installation script..."
        ./klipper/scripts/install-octopi.sh
        echo -e "${GREEN}Klipper installation complete.${NC}"
    fi
    read -p "Press Enter to continue..."
}

install_moonraker() {
    echo -e "${YELLOW}Installing Moonraker...${NC}"
    if [ -d "${HOME}/moonraker" ]; then
        echo -e "${GREEN}Moonraker is already installed.${NC}"
    else
        echo "Cloning Moonraker repository..."
        cd "${HOME}"
        git clone https://github.com/Arksine/moonraker.git
        echo "Running Moonraker installation script..."
        ./moonraker/scripts/install-moonraker.sh
        echo -e "${GREEN}Moonraker installation complete.${NC}"
    fi
    read -p "Press Enter to continue..."
}

install_probe_tech() {
    echo -e "${YELLOW}Installing Probe Tech Control...${NC}"
    
    # 1. Ensure config dir exists
    if [ ! -d "$CONFIG_DIR" ]; then
        echo -e "${YELLOW}Configuration directory not found. Creating $CONFIG_DIR...${NC}"
        mkdir -p "$CONFIG_DIR"
    fi

    # 2. Copy Config
    if [ ! -f "probe_tech.cfg" ]; then
        echo -e "${RED}Error: probe_tech.cfg source file missing!${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    cp probe_tech.cfg "$PROBE_TECH_CFG"
    echo -e "${GREEN}✓ probe_tech.cfg copied${NC}"

    # 3. Update printer.cfg
    if [ -f "$PRINTER_CFG" ]; then
        if grep -q "include probe_tech.cfg" "$PRINTER_CFG"; then
            echo -e "${YELLOW}! Link already exists in printer.cfg${NC}"
        else
            sed -i '1s/^/[include probe_tech.cfg]\n/' "$PRINTER_CFG"
            echo -e "${GREEN}✓ Linked in printer.cfg${NC}"
        fi
    else
         echo -e "${RED}! printer.cfg not found. Please verify your Klipper setup.${NC}"
    fi

    # 4. Update Moonraker
    if [ -f "$MOONRAKER_CONF" ]; then
        if grep -q "\[update_manager client probe_tech\]" "$MOONRAKER_CONF"; then
            echo -e "${YELLOW}! Moonraker already configured${NC}"
        else
            cat <<EOF >> "$MOONRAKER_CONF"

[update_manager client probe_tech]
type: web
channel: stable
repo: PravarHegde/probe-tech-control
path: ~/probe-tech-control
EOF
            echo -e "${GREEN}✓ Configured Moonraker Update Manager${NC}"
        fi
    else
        echo -e "${RED}! moonraker.conf not found. Is Moonraker installed?${NC}"
    fi

    # 5. Install Systemd Service
    echo -e "${YELLOW}Installing Systemd Service...${NC}"
    if [ ! -f "probe-tech.service" ]; then
         echo -e "${RED}Error: probe-tech.service template missing!${NC}"
    else
         # Replace {USER} placeholder
         sed "s/{USER}/${CURRENT_USER}/g" probe-tech.service > /tmp/probe-tech.service
         sudo mv /tmp/probe-tech.service "$SERVICE_FILE"
         sudo systemctl daemon-reload
         sudo systemctl enable probe-tech.service
         sudo systemctl start probe-tech.service
         echo -e "${GREEN}✓ Service installed and started${NC}"
    fi
    
    echo -e "${GREEN}Probe Tech Control setup complete!${NC}"
    read -p "Press Enter to continue..."
}

uninstall_config() {
    echo -e "${YELLOW}Uninstalling Probe Tech Config...${NC}"
    if [ -f "$PROBE_TECH_CFG" ]; then
        rm "$PROBE_TECH_CFG"
        echo -e "${GREEN}✓ Removed config file${NC}"
    fi
    if [ -f "$PRINTER_CFG" ]; then
        sed -i '/\[include probe_tech.cfg\]/d' "$PRINTER_CFG"
        echo -e "${GREEN}✓ Removed link from printer.cfg${NC}"
    fi
    
    # Stop Service
    if systemctl is-active --quiet probe-tech; then
        sudo systemctl stop probe-tech
        sudo systemctl disable probe-tech
        echo -e "${GREEN}✓ Service stopped and disabled${NC}"
    fi
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE"
        sudo systemctl daemon-reload
        echo -e "${GREEN}✓ Service file removed${NC}"
    fi

    echo -e "${YELLOW}! Please manually remove the update_manager block from moonraker.conf${NC}"
    read -p "Press Enter to continue..."
}

service_menu() {
    while true; do
        clear
        echo -e "${CYAN}=================================================${NC}"
        echo -e "${CYAN}            SERVICE CONTROL (SYSTEM MD)          ${NC}"
        echo -e "${CYAN}=================================================${NC}"
        
        if systemctl is-active --quiet probe-tech; then
            echo -e "Status: ${GREEN}Active (Running)${NC}"
        else
            echo -e "Status: ${RED}Inactive (Stopped)${NC}"
        fi
        
        if systemctl is-enabled --quiet probe-tech 2>/dev/null; then
             echo -e "Boot:   ${GREEN}Enabled${NC}"
        else
             echo -e "Boot:   ${RED}Disabled${NC}"
        fi
        echo ""

        echo "1) Start Server"
        echo "2) Stop Server"
        echo "3) Restart Server"
        echo "4) Enable on Boot"
        echo "5) Disable on Boot"
        echo "B) Back to Main Menu"
        echo ""
        read -p "Select an option: " s_choice

        case $s_choice in
            1) sudo systemctl start probe-tech ;;
            2) sudo systemctl stop probe-tech ;;
            3) sudo systemctl restart probe-tech ;;
            4) sudo systemctl enable probe-tech ;;
            5) sudo systemctl disable probe-tech ;;
            b|B) break ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# --- MAIN LOOP ---

while true; do
    print_header
    check_status
    
    echo "1) Install / Update Probe Tech Control"
    echo "2) Install Moonraker"
    echo "3) Install Klipper"
    echo "4) Service Control (System MD)"
    echo "5) Uninstall Probe Tech Config"
    echo "Q) Quit"
    echo ""
    read -p "Select an option (Ordered by workflow): " choice

    case $choice in
        1) install_probe_tech ;;
        2) install_moonraker ;;
        3) install_klipper ;;
        4) service_menu ;;
        5) uninstall_config ;;
        q|Q) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
done
