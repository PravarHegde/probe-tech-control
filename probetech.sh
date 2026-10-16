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

# Ensure core prerequisites exist on fresh Raspberry Pi OS Lite
MISSING_PKGS=()
for pkg in git curl wget build-essential python3 python3-pip python3-venv; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${GOLD}Fresh OS detected. Installing system prerequisites: ${MISSING_PKGS[*]}...${NC}"
    sudo apt update -y && sudo apt install -y "${MISSING_PKGS[@]}"
fi

# Target directory
TARGET_DIR="${HOME}/ptc"

# Cleanup if exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${GOLD}Cleaning up previous installer files...${NC}"
    rm -rf "$TARGET_DIR"
fi

# Use modern partial clone to download ONLY the needed scripts (no history, no blobs/files initially)
echo -e "${BLUE}Fetching installer repository...${NC}"
mkdir -p "$TARGET_DIR"
git clone -b "${PROBETECH_BRANCH:-develop}" --depth 1 --filter=blob:none --sparse https://github.com/PravarHegde/probe-tech-control.git "$TARGET_DIR"

cd "$TARGET_DIR" || exit 1

# Explicitly select only the files we need (Ignoring everything else, like the big zip)
# Explicitly select only the files we need (Ignoring everything else, like the big zip)
echo -e "${BLUE}Checking out scripts...${NC}"
git sparse-checkout init --no-cone
git sparse-checkout set /install.sh /scripts/* /probe_tech.cfg /requirements.txt /probe-tech-control.zip

# Run the installer
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh "$@"
