#!/bin/bash

# Probe Tech Control Advanced Installer and Manager
# A KIAUH-like system for managing Klipper/Moonraker/Probe Tech instances

# --- VARIABLES ---
HOME_DIR="${HOME}"
USER=$(whoami)
SERVICE_TEMPLATE="probe-tech.service"
BACKUP_DIR="${HOME}/probe_tech_backups"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- UTILS ---

print_header() {
    clear
    echo -e "${CYAN}=================================================${NC}"
    echo -e "${CYAN}      PROBE TECH CONTROL - ADVANCED MANAGER      ${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo ""
}

# Returns array of printer instances (dirs starting with printer_data or printer_X_data)
# Formats as "1: printer_data" "2: printer_c_data" etc.
get_instances() {
    find "${HOME}" -maxdepth 1 -type d -name "printer*_data" | sort
}

select_instance() {
    echo -e "${YELLOW}Select Klipper Instance:${NC}"
    instances=($(get_instances))
    
    if [ ${#instances[@]} -eq 0 ]; then
        echo -e "${RED}No Klipper instances found! (folder pattern: ~/printer*_data)${NC}"
        return 1
    fi

    i=1
    for inst in "${instances[@]}"; do
        echo "$i) $(basename "$inst")"
        ((i++))
    done
    
    read -p "Enter number: " sel
    
    if [[ ! "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt ${#instances[@]} ]; then
        echo -e "${RED}Invalid selection.${NC}"
        return 1
    fi
    
    # Return selected path relative to 0-index array
    SELECTED_INSTANCE="${instances[$((sel-1))]}"
    SELECTED_CONF_DIR="${SELECTED_INSTANCE}/config"
    echo -e "Selected: ${GREEN}${SELECTED_INSTANCE}${NC}"
    return 0
}

# --- ACTIONS ---

install_klipper() {
    echo -e "${YELLOW}Installing Klipper (Standard)...${NC}"
    if [ -d "${HOME}/klipper" ]; then
        echo -e "${GREEN}Klipper repo detected.${NC}"
    else
        cd "${HOME}"
        git clone https://github.com/Klipper3d/klipper.git
    fi
    # Run official script
    if [ -f "${HOME}/klipper/scripts/install-octopi.sh" ]; then
         ${HOME}/klipper/scripts/install-octopi.sh
    else
         echo -e "${RED}Installer script not found.${NC}"
    fi
    read -p "Press Enter..."
}

install_moonraker() {
    echo -e "${YELLOW}Installing Moonraker (Standard)...${NC}"
    if [ -d "${HOME}/moonraker" ]; then
        echo -e "${GREEN}Moonraker repo detected.${NC}"
    else
        cd "${HOME}"
        git clone https://github.com/Arksine/moonraker.git
    fi
    if [ -f "${HOME}/moonraker/scripts/install-moonraker.sh" ]; then
         ${HOME}/moonraker/scripts/install-moonraker.sh
    else
         echo -e "${RED}Installer script not found.${NC}"
    fi
    read -p "Press Enter..."
}

install_probe_tech() {
    if ! select_instance; then return; fi
    
    echo -e "${YELLOW}Installing Probe Tech for $(basename "$SELECTED_INSTANCE")...${NC}"
    
    PROBE_CFG="${SELECTED_CONF_DIR}/probe_tech.cfg"
    PRINTER_CFG="${SELECTED_CONF_DIR}/printer.cfg"
    MOONRAKER_CONF="${SELECTED_CONF_DIR}/moonraker.conf"
    
    # 1. Config
    if [ -f "probe_tech.cfg" ]; then
        cp probe_tech.cfg "$PROBE_CFG"
        echo -e "${GREEN}✓ Copied probe_tech.cfg${NC}"
    else
        echo -e "${RED}Error: probe_tech.cfg missing in installer dir.${NC}"
        read -p "Press Enter..."
        return
    fi
    
    # 2. Printer.cfg
    if [ -f "$PRINTER_CFG" ]; then
        if ! grep -q "include probe_tech.cfg" "$PRINTER_CFG"; then
            sed -i '1s/^/[include probe_tech.cfg]\n/' "$PRINTER_CFG"
            echo -e "${GREEN}✓ Included in printer.cfg${NC}"
        else
            echo -e "${YELLOW}Already link in printer.cfg${NC}"
        fi
    fi
    
    # 3. Moonraker
    if [ -f "$MOONRAKER_CONF" ]; then
         if ! grep -q "\[update_manager client probe_tech\]" "$MOONRAKER_CONF"; then
             cat <<EOF >> "$MOONRAKER_CONF"

[update_manager client probe_tech]
type: web
channel: stable
repo: PravarHegde/probe-tech-control
path: ~/probe-tech-control
EOF
             echo -e "${GREEN}✓ Configured Moonraker${NC}"
         else
             echo -e "${YELLOW}Moonraker already configured${NC}"
         fi
    fi
    
    # 4. Service
    echo -e "${YELLOW}Installing Systemd Server Service...${NC}"
    if [ -f "probe-tech.service" ]; then
         sed "s/{USER}/${USER}/g" probe-tech.service > /tmp/probe-tech.service
         sudo mv /tmp/probe-tech.service "/etc/systemd/system/probe-tech.service"
         sudo systemctl daemon-reload
         sudo systemctl enable probe-tech.service
         sudo systemctl start probe-tech.service
         echo -e "${GREEN}✓ Service Active${NC}"
    fi
    
    echo -e "${GREEN}Done!${NC}"
    read -p "Press Enter..."
}

backup_instance() {
    if ! select_instance; then return; fi
    mkdir -p "$BACKUP_DIR"
    
    name=$(basename "$SELECTED_INSTANCE")
    ts=$(date +%Y%m%d_%H%M%S)
    tarfile="${BACKUP_DIR}/${name}_backup_${ts}.tar.gz"
    
    echo -e "${YELLOW}Backing up $name to $tarfile...${NC}"
    tar -czf "$tarfile" -C "${HOME}" "$name"
    
    echo -e "${GREEN}Backup Complete!${NC}"
    read -p "Press Enter..."
}

remove_probe_tech() {
    if ! select_instance; then return; fi
    
    PROBE_CFG="${SELECTED_CONF_DIR}/probe_tech.cfg"
    PRINTER_CFG="${SELECTED_CONF_DIR}/printer.cfg"
    
    echo -e "${YELLOW}Removing Probe Tech Config from $(basename "$SELECTED_INSTANCE")...${NC}"
    
    if [ -f "$PROBE_CFG" ]; then
        rm "$PROBE_CFG"
        echo -e "${GREEN}✓ Removed probe_tech.cfg${NC}"
    fi
    
    if [ -f "$PRINTER_CFG" ]; then
        sed -i '/\[include probe_tech.cfg\]/d' "$PRINTER_CFG"
        echo -e "${GREEN}✓ Cleaned printer.cfg${NC}"
    fi
    
    echo -e "${YELLOW}Note: Manually remove update_manager block from moonraker.conf${NC}"
    read -p "Press Enter..."
}

# --- MENUS ---

menu_install() {
    while true; do
        print_header
        echo -e "${CYAN}--- INSTALLATION MENU ---${NC}"
        echo "1) Install Klipper"
        echo "2) Install Moonraker"
        echo "3) Install Probe Tech Control (Single Instance)"
        echo "4) Back to Main Menu"
        echo ""
        read -p "Select: " c
        case $c in
            1) install_klipper ;;
            2) install_moonraker ;;
            3) install_probe_tech ;;
            4) return ;;
            *) ;;
        esac
    done
}

menu_service() {
    while true; do
        print_header
        echo -e "${CYAN}--- SERVICE CONTROL ---${NC}"
        echo "1) Start Probe Tech Server"
        echo "2) Stop Probe Tech Server"
        echo "3) Restart Probe Tech Server"
        echo "4) Enable on Boot"
        echo "5) Disable on Boot"
        echo "6) Back to Main Menu"
        echo ""
        read -p "Select: " c
        case $c in
            1) sudo systemctl start probe-tech ;;
            2) sudo systemctl stop probe-tech ;;
            3) sudo systemctl restart probe-tech ;;
            4) sudo systemctl enable probe-tech ;;
            5) sudo systemctl disable probe-tech ;;
            6) return ;;
        esac
    done
}

menu_backup() {
    while true; do
        print_header
        echo -e "${CYAN}--- BACKUP & RESTORE ---${NC}"
        echo "1) Backup Instance Configuration"
        echo "2) Back to Main Menu"
        echo ""
        read -p "Select: " c
        case $c in
            1) backup_instance ;;
            2) return ;;
        esac
    done
}

menu_remove() {
    while true; do
        print_header
        echo -e "${CYAN}--- REMOVE MENU ---${NC}"
        echo "1) Remove Probe Tech Config"
        echo "2) Back to Main Menu"
        echo ""
        read -p "Select: " c
        case $c in
            1) remove_probe_tech ;;
            2) return ;;
        esac
    done
}

# --- MAIN ---

while true; do
    print_header
    echo "1) Install / Update"
    echo "2) Remove"
    echo "3) Backup"
    echo "4) Service Control"
    echo "5) Quit"
    echo ""
    read -p "Select option: " main_c
    
    case $main_c in
        1) menu_install ;;
        2) menu_remove ;;
        3) menu_backup ;;
        4) menu_service ;;
        5) exit 0 ;;
        *) ;;
    esac
done
