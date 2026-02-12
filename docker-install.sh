#!/bin/bash

# Probe Tech Control - Full-Stack Docker Automated Installer
# Version: v2.0.0

# Colors
BLUE='\033[1;34m'
GOLD='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_box() {
    echo -e "${BLUE}=====================================================================${NC}"
    echo -e "${GOLD}      $1      ${NC}"
    echo -e "${BLUE}=====================================================================${NC}"
}

echo -e "${BLUE}Starting Probe Tech Control Full-Stack Docker Installer...${NC}"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found!${NC}"
    echo -e "${GOLD}Please install Docker first: https://docs.docker.com/get-docker/${NC}"
    exit 1
fi

# Ensure Docker starts on boot
echo -e "${BLUE}Ensuring Docker starts on boot...${NC}"
sudo systemctl enable docker &> /dev/null
sudo systemctl start docker &> /dev/null

# Check for Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose V2 not found!${NC}"
    echo -e "${GOLD}Please install Docker Compose V2.${NC}"
    exit 1
fi

print_box "FULL-STACK DOCKER DEPLOYMENT"

# Check for branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo -e "Current Branch: ${GREEN}${CURRENT_BRANCH}${NC}"

if [ "$CURRENT_BRANCH" != "docker-develop" ]; then
    echo -e "${GOLD}Warning: You are not on the 'docker-develop' branch.${NC}"
    read -p "Do you want to switch to 'docker-develop'? (y/n): " switch_branch
    if [[ "$switch_branch" =~ ^[Yy]$ ]]; then
        git checkout docker-develop || git checkout -b docker-develop
    fi
fi

# Ensure data directories exist
echo -e "${BLUE}Setting up data directories...${NC}"
mkdir -p ./printer_data/config ./printer_data/logs ./printer_data/comms

# Check if printer.cfg exists, if not create a placeholder
if [ ! -f "./printer_data/config/printer.cfg" ]; then
    echo -e "${GOLD}Creating default printer.cfg...${NC}"
    cat <<EOF > "./printer_data/config/printer.cfg"
[mcu]
serial: /dev/serial/by-id/PLEASE_UPDATE_ME

[printer]
kinematics: none
max_velocity: 300
max_accel: 3000
EOF
fi

# Check if moonraker.conf exists, if not create a placeholder
if [ ! -f "./printer_data/config/moonraker.conf" ]; then
    echo -e "${GOLD}Creating default moonraker.conf...${NC}"
    cat <<EOF > "./printer_data/config/moonraker.conf"
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: /opt/printer_data/comms/klippy.sock

[authorization]
cors_domains:
    *
trusted_clients:
    127.0.0.1
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    FE80::/10
    ::1/128

[update_manager]
EOF
fi

# Permissions check
echo -e "${BLUE}Checking user permissions for serial access...${NC}"
if ! groups $USER | grep &>/dev/null "dialout"; then
    echo -e "${GOLD}Adding user $USER to 'dialout' group for serial access...${NC}"
    sudo usermod -aG dialout $USER
    echo -e "${RED}WARNING: You may need to logout and login for group changes to take effect.${NC}"
fi

echo -e "${BLUE}Building and starting containers...${NC}"
docker compose up --build -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${GREEN}✓ Probe Tech Control Full-Stack is now running in Docker!${NC}"
    echo -e "${GOLD}UI:         http://localhost:8080${NC}"
    echo -e "${GOLD}Klipper:    Running (Container: klipper)${NC}"
    echo -e "${GOLD}Moonraker:  Running (Container: moonraker)${NC}"
    echo -e "${GREEN}=====================================================================${NC}"
else
    echo -e "${RED}Failed to start containers. Check logs with 'docker compose logs'${NC}"
fi
