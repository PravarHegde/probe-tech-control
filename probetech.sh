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
# Clone repository (Optimized <1MB)
echo -e "${BLUE}Fetching installer...${NC}"
mkdir -p "$TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    # Clear directory to ensure clean clone
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Use modern partial clone to download ONLY the needed scripts (no history, no blobs/files initially)
echo -e "${BLUE}Initializing partial clone...${NC}"
git clone --depth 1 --filter=blob:none --sparse https://github.com/PravarHegde/probe-tech-control.git "$TARGET_DIR"

cd "$TARGET_DIR" || exit 1

# Explicitly select only the files we need (Ignoring everything else, like the big zip)
# Explicitly select only the files we need (Ignoring everything else, like the big zip)
echo -e "${BLUE}Checking out scripts...${NC}"
git sparse-checkout init --no-cone
git sparse-checkout set install.sh scripts/* requirements.txt

# Run the installer
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh
