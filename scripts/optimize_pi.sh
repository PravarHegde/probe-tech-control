#!/bin/bash
# Raspberry Pi Optimization Script
# Removes bloatware while keeping Basic UI + Chromium

echo "Starting Optimization..."

# List of packages to remove
PACKAGES_TO_REMOVE=(
    libreoffice*
    wolfram-engine
    minecraft-pi
    sonic-pi
    scratch*
    sense-hat
    sense-emu-tools
    thole
    smartsim
    debian-reference-en
    dillo
    nuscratch
    python3-thonny
)

echo "Removing Packages: ${PACKAGES_TO_REMOVE[*]}"
sudo apt-get remove --purge -y "${PACKAGES_TO_REMOVE[@]}"

echo "Autoremoving dependencies..."
sudo apt-get autoremove -y

echo "Cleaning cache..."
sudo apt-get clean

echo "Optimization Complete."
echo "Remaining: Chromium, Text Editor, Desktop Environment."
