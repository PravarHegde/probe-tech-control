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
# Clone repository (Sparse Checkout for speed <1MB)
echo -e "${BLUE}Fetching installer...${NC}"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

# Initialize and pull only install.sh + scripts
if [ ! -d ".git" ]; then
    git init -q
    git remote add origin https://github.com/PravarHegde/probe-tech-control.git
fi

git config core.sparseCheckout true
echo "install.sh" > .git/info/sparse-checkout
echo "scripts/" >> .git/info/sparse-checkout
echo "requirements.txt" >> .git/info/sparse-checkout

echo -e "${BLUE}Downloading files...${NC}"
git pull --depth 1 origin master

# Run the installer
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh
