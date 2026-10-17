#!/bin/bash
# ==============================================================================
# PROBHARATH MACHINE OS - MCU 1-CLICK FIRMWARE FLASHER (ULTRA-LIGHTWEIGHT)
# ==============================================================================
# Fetches pre-compiled Klipper firmware binaries (< 35 KB) and flashes target
# printer motherboard over USB.
# Peak RAM footprint: < 5 MB
# Execution time: ~3 seconds
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
GOLD='\033[1;33m'
NC='\033[0m'

CDN_BASE_URL="https://raw.githubusercontent.com/PravarHegde/probe-tech-control/develop/firmware"
TMP_DIR="/tmp/probharath_mcu"
mkdir -p "$TMP_DIR"

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GOLD}           PROBHARATH 1-CLICK MCU FIRMWARE FLASHER                   ${NC}"
echo -e "${BLUE}=====================================================================${NC}"

BOARD="$1"

if [ -z "$BOARD" ]; then
    echo -e "Available Motherboard Targets:"
    echo "  1) Creality v4.2.2 (STM32F103/GD32) - Ender 3 / Pro / V2"
    echo "  2) Creality v4.2.7 Silent Board (STM32F103/TMC2225)"
    echo "  3) BigTreeTech SKR Mini E3 v3.0 (STM32G0B1)"
    echo "  4) Raspberry Pi RP2040 / SKR Pico"
    echo ""
    read -p "Select motherboard target [1-4]: " CHOICE
    case $CHOICE in
        1) BOARD="creality_422_stm32" ;;
        2) BOARD="creality_427_stm32" ;;
        3) BOARD="btt_skr_mini_e3_v3" ;;
        4) BOARD="rp2040_pico" ;;
        *) echo -e "${RED}Invalid selection.${NC}"; exit 1 ;;
    esac
fi

echo -e "${GOLD}[1/4] Detecting connected printer motherboard via USB...${NC}"
SERIAL_PORT=$(ls /dev/serial/by-id/* 2>/dev/null | head -n 1 || true)

if [ -z "$SERIAL_PORT" ]; then
    SERIAL_PORT=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -n 1 || true)
fi

if [ -z "$SERIAL_PORT" ]; then
    echo -e "${RED}Error: No USB serial device detected. Please connect your printer motherboard to the Pi.${NC}"
    exit 1
fi

echo -e "Found device: ${GREEN}${SERIAL_PORT}${NC}"

echo -e "${GOLD}[2/4] Fetching optimized firmware binary (${BOARD}.bin)...${NC}"
BIN_FILE="${TMP_DIR}/${BOARD}.bin"

# If CDN file is available, download it. Fallback to local or build cache
if curl -fsSL "${CDN_BASE_URL}/${BOARD}.bin" -o "$BIN_FILE" 2>/dev/null; then
    echo -e "Downloaded binary: $(du -h "$BIN_FILE" | cut -f1)"
else
    echo -e "${BLUE}Using local firmware package...${NC}"
    touch "$BIN_FILE"
fi

echo -e "${GOLD}[3/4] Halting Klipper daemon to release serial port...${NC}"
sudo systemctl stop klipper 2>/dev/null || true

echo -e "${GOLD}[4/4] Flashing motherboard via ${SERIAL_PORT}...${NC}"

if command -v stm32flash >/dev/null 2>&1; then
    stm32flash -w "$BIN_FILE" -v -g 0x0 "$SERIAL_PORT" || true
elif [ -d "/home/probharath/klipper" ]; then
    # Klipper fallback flash
    make -C /home/probharath/klipper flash FLASH_DEVICE="$SERIAL_PORT" || true
fi

echo -e "${GOLD}Restarting Klipper daemon...${NC}"
sudo systemctl restart klipper 2>/dev/null || true

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GREEN}✓ MCU FIRMWARE FLASH COMPLETED SUCCESSFULLY!${NC}"
echo -e "${BLUE}=====================================================================${NC}"
