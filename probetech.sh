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

# Ensure reliable DNS (prefers 8.8.8.8 and 1.1.1.1 to avoid router ISP DNS timeouts)
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${RED}Warning: No external network ping available.${NC}"
else
    # Prepend reliable DNS servers if not already present
    if ! grep -q "8.8.8.8" /etc/resolv.conf 2>/dev/null; then
        echo -e "${BLUE}Configuring high-speed DNS resolvers...${NC}"
        sudo sed -i '1s/^/nameserver 8.8.8.8\nnameserver 1.1.1.1\n/' /etc/resolv.conf 2>/dev/null || true
    fi
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

