#!/bin/bash

# Probe Tech Control - Advanced Docker Manager
# Version: v1.0.0

# --- SETTINGS ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Colors
BLUE='\033[1;34m'
GOLD='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[1;36m'
NC='\033[0m'

# --- UTILS ---

print_box() {
    local text="$1"
    local color="$2"
    echo -e "${BLUE}=====================================================================${NC}"
    echo -e "${color}      $text      ${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
}

get_ip() {
    hostname -I | awk '{print $1}'
}

check_status() {
    print_box "PROBE TECH CONTROL - DOCKER MANAGER" "${GOLD}"
    
    local containers=$(docker compose ps --format "table {{.Name}}\t{{.Status}}")
    if [ -z "$containers" ]; then
        echo -e "${RED}No containers found. Is the stack running?${NC}"
    else
        echo -e "${BLUE}--- Container Status ---${NC}"
        echo "$containers" | sed 's/Up/  \x1b[32mUp\x1b[0m/' | sed 's/Exited/  \x1b[31mExited\x1b[0m/'
    fi

    echo ""
    local ip=$(get_ip)
    echo -e "Web Interface:      ${GOLD}http://${ip}:8080${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
    echo ""
}

# --- MENU ACTIONS ---

menu_services() {
    while true; do
        clear
        print_box "SERVICE CONTROL" "${BLUE}"
        echo "1) Restart All Containers"
        echo "2) Stop All Containers"
        echo "3) Start All Containers"
        echo "4) Restart Individual Container"
        echo "5) Back"
        echo ""
        read -p "Select: " c < /dev/tty
        case $c in
            1) docker compose restart ;;
            2) docker compose stop ;;
            3) docker compose start ;;
            4) 
                echo "1) UI  2) Moonraker  3) Klipper"
                read -p "Choose: " sc < /dev/tty
                [ "$sc" == "1" ] && docker compose restart probe-tech-control
                [ "$sc" == "2" ] && docker compose restart moonraker
                [ "$sc" == "3" ] && docker compose restart klipper
                ;;
            5) return ;;
        esac
    done
}

menu_system() {
    while true; do
        clear
        print_box "SYSTEM CONTROL" "${RED}"
        echo "1) Restart Host System (Reboot)"
        echo "2) Shutdown Host System"
        echo "3) Back"
        echo ""
        read -p "Select: " c < /dev/tty
        case $c in
            1) 
                echo -e "${RED}System will reboot now!${NC}"
                sudo reboot
                ;;
            2) 
                echo -e "${RED}System will shutdown now!${NC}"
                sudo shutdown -h now
                ;;
            3) return ;;
        esac
    done
}

view_logs() {
    print_box "VIEWING LOGS (Ctrl+C to Exit)" "${CYAN}"
    docker compose logs -f --tail=100
}

menu_config() {
    while true; do
        clear
        print_box "CONFIGURATION" "${GOLD}"
        echo "1) Edit printer.cfg"
        echo "2) Edit moonraker.conf"
        echo "3) Back"
        echo ""
        read -p "Select: " c < /dev/tty
        case $c in
            1) nano ./printer_data/config/printer.cfg ;;
            2) nano ./printer_data/config/moonraker.conf ;;
            3) return ;;
        esac
    done
}

menu_network() {
    clear
    print_box "WIFI & NETWORK INFO" "${MAGENTA}"
    local ip=$(get_ip)
    echo -e "System IP: ${GOLD}${ip}${NC}"
    echo ""
    echo -e "${BLUE}--- Network Interfaces ---${NC}"
    ip -4 addr show | grep -E "inet|mtu" | grep -v "127.0.0.1"
    echo ""
    if command -v nmtui &> /dev/null; then
        echo "Launch WiFi Config (nmtui)? (y/n)"
        read -p "> " n < /dev/tty
        [[ "$n" == "y" ]] && sudo nmtui
    fi
    read -p "Press Enter to return..." < /dev/tty
}

repair_stack() {
    print_box "AUTO-FIX / REPAIR" "${GOLD}"
    echo -e "${SILVER}Re-initializing directories and permissions...${NC}"
    mkdir -p ./printer_data/config ./printer_data/logs ./printer_data/comms
    sudo usermod -aG dialout $USER
    echo -e "${BLUE}Restarting containers...${NC}"
    docker compose up -d
    echo -e "${GREEN}✓ Repair attempts complete.${NC}"
    read -p "Press Enter..." < /dev/tty
}

update_stack() {
    print_box "UPDATING STACK" "${CYAN}"
    echo -e "${GOLD}Pulling latest changes and rebuilding...${NC}"
    git pull origin docker-develop
    docker compose up --build -d
    echo -e "${GREEN}Update complete.${NC}"
    read -p "Press Enter..." < /dev/tty
}

# --- MAIN LOOP ---

while true; do
    clear
    check_status
    
    echo "1) Service Control (Start / Stop / Restart)"
    echo "2) View Live Logs"
    echo "3) Edit Configuration Files"
    echo "4) Update Stack (Git Pull + Rebuild)"
    echo "5) Shell Access (Terminal in Container)"
    echo "6) WiFi & Network Info"
    echo "7) Auto-Fix / Repair"
    echo "8) System Control (Reboot / Shutdown)"
    echo "9) Exit"
    echo ""
    read -p "Select option: " main_c < /dev/tty
    
    case $main_c in
        1) menu_services ;;
        2) view_logs ;;
        3) menu_config ;;
        4) update_stack ;;
        5) 
            echo "1) Moonraker  2) Klipper"
            read -p "Access which? " asel < /dev/tty
            [ "$asel" == "1" ] && docker compose exec moonraker /bin/sh
            [ "$asel" == "2" ] && docker compose exec klipper /bin/sh
            ;;
        6) menu_network ;;
        7) repair_stack ;;
        8) menu_system ;;
        9) exit 0 ;;
        *) ;;
    esac
done
