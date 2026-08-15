<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Probharath Machines - Master Configuration Directory

Welcome to the root directory for all officially supported Probharath Technologies hardware.

We have structured our configurations into distinct product lineups. Each folder below contains the master `printer.cfg` (or machine config) for that specific motherboard, along with detailed hardware pinouts and schematics for PCB designers and end-users.

## Product Lineups

### 1. Auro O Series (`/Auro_O`)
Our ultra-budget, highly efficient 48-pin STM32F401 3D printer motherboards.
- **Light:** Standalone drivers, no screen support.
- **Standard:** Shared UART TMC drivers, screen support.
- **Pure:** Dedicated UART TMC drivers, no screen support.
- **Pro:** Dual-extruder (IDEX) support.

### 2. Elite O Series (`/Elite_O`)
Our premium tier 64-pin STM32G0B1 motherboard. Designed for high-end CoreXY machines requiring more IO, robust power delivery, and advanced Klipper features natively on the board.

### 3. Matrixs (`/Matrixs`)
Our advanced dual-MCU architecture, utilizing CAN bus communication for massively scalable multi-toolhead 3D printing.

### 4. Titan CNC O (`/Titan_CNC_O`)
Our heavy-duty board engineered specifically for CNC routing and laser engraving machines, featuring higher voltage stepper support and dedicated spindle/laser PWM controls.
