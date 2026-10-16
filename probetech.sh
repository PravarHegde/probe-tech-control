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

# Ensure DNS resolution is ready
echo -e "${BLUE}Verifying internet connection and DNS...${NC}"
if ! host github.com >/dev/null 2>&1 && ! ping -c 1 -W 2 github.com >/dev/null 2>&1; then
    echo -e "${GOLD}Adding public DNS fallback (8.8.8.8, 1.1.1.1)...${NC}"
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf >/dev/null 2>&1 || true
    sleep 1
fi

# Robust clone with retry
echo -e "${BLUE}Fetching installer repository...${NC}"
mkdir -p "$TARGET_DIR"

CLONE_SUCCESS=0
for attempt in 1 2 3; do
    if git clone -b "${PROBETECH_BRANCH:-develop}" --depth 1 --filter=blob:none --sparse https://github.com/PravarHegde/probe-tech-control.git "$TARGET_DIR"; then
        CLONE_SUCCESS=1
        break
    else
        echo -e "${GOLD}Git clone attempt $attempt failed. Retrying in 2 seconds...${NC}"
        rm -rf "$TARGET_DIR"
        mkdir -p "$TARGET_DIR"
        sleep 2
    fi
done

if [ "$CLONE_SUCCESS" -ne 1 ]; then
    echo -e "${RED}Failed to clone repository from GitHub. Please check your internet connection.${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit 1

# Explicitly select only the files we need (Ignoring everything else, like the big zip)
echo -e "${BLUE}Checking out scripts...${NC}"
git sparse-checkout init --no-cone
git sparse-checkout set /install.sh /scripts/* /probe_tech.cfg /requirements.txt /probe-tech-control.zip

if [ ! -f "install.sh" ]; then
    echo -e "${RED}Error: install.sh not found after sparse-checkout.${NC}"
    exit 1
fi

# Run the installer
chmod +x install.sh
./install.sh "$@"

