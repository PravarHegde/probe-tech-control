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

# Fetch scripts directly via archive tarball (fast, reliable, no git filter issues)
echo -e "${BLUE}Fetching installer files...${NC}"
mkdir -p "$TARGET_DIR"

FETCH_SUCCESS=0
if curl -fsSL "https://codeload.github.com/PravarHegde/probe-tech-control/tar.gz/refs/heads/${PROBETECH_BRANCH:-develop}" | tar -xz -C "$TARGET_DIR" --strip-components=1 2>/dev/null; then
    FETCH_SUCCESS=1
elif wget -qO- "https://codeload.github.com/PravarHegde/probe-tech-control/tar.gz/refs/heads/${PROBETECH_BRANCH:-develop}" | tar -xz -C "$TARGET_DIR" --strip-components=1 2>/dev/null; then
    FETCH_SUCCESS=1
else
    echo -e "${GOLD}Tarball download failed, falling back to git clone...${NC}"
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    if git clone --depth 1 -b "${PROBETECH_BRANCH:-develop}" https://github.com/PravarHegde/probe-tech-control.git "$TARGET_DIR"; then
        FETCH_SUCCESS=1
    fi
fi

if [ "$FETCH_SUCCESS" -ne 1 ] || [ ! -f "$TARGET_DIR/install.sh" ]; then
    echo -e "${RED}Failed to download installer files. Please check your network connection.${NC}"
    exit 1
fi

cd "$TARGET_DIR" || exit 1


# Run the installer
chmod +x install.sh
./install.sh "$@"

