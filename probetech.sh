#!/bin/bash
# probetech.sh - Quick Installer for Probe Tech Control
# This script automates the cloning and installation process.

# Colors
GOLD='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GOLD}           PROBE TECH CONTROL - QUICK INSTALLER              ${NC}"
echo -e "${BLUE}=====================================================================${NC}"

# Target directory
TARGET_DIR="${HOME}/ptc"

# Cleanup if exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${GOLD}Cleaning up previous installer files...${NC}"
    rm -rf "$TARGET_DIR"
fi

# Clone the repository
echo -e "${BLUE}Cloning repository (Shallow)...${NC}"
# Clone the repository
echo -e "${BLUE}Cloning repository (Shallow)...${NC}"
git clone --depth 1 https://github.com/PravarHegde/probe-tech-control.git "$TARGET_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Failed to clone repository."
    exit 1
fi

# Run the installer
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh
