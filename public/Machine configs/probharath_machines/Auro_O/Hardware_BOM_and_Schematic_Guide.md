<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Auro O: Hardware BOM & Schematic Guide

This document provides Electrical Engineers and PCB Designers with the comprehensive schematic-level requirements and Bill of Materials (BOM) needed to physically manufacture the Auro O motherboard.

Because the Auro O supports 12V and 24V inputs interchangeably and uses standard replaceable automotive fuses, it is highly durable and repairable.

---

## 1. Connector Manifest (Sockets & Terminals)

To manufacture the physical board, you will need to place the following physical connectors.

### High-Current Screw Terminals
- **1x 2-Pin Terminal (15A+ Rating):** Main Power Input (VIN / GND)
- **1x 2-Pin Terminal (15A+ Rating):** Heated Bed Output
- **2x 2-Pin Terminal (5A+ Rating):** Hotend 0 & Hotend 1 Outputs

### JST-XH 2.54mm Connectors
- **4x 4-Pin JST-XH:** Stepper Motors (X, Y, Z, E0)
- **1x 4-Pin JST-XH:** 2nd Stepper Motor (E1 / Z2)
- **3x 2-Pin JST-XH:** Thermistors (Bed, Hotend 0, Hotend 1)
- **3x 3-Pin JST-XH:** Endstops (X, Y, Z) - *(VCC, GND, Signal)*
- **3x 2-Pin JST-XH:** PWM Fans (Part Fan, Hotend 0 Fan, Hotend 1 Fan)
- **1x 5-Pin JST-XH:** BLTouch / Probe (Servo Control + Sensor)
- **1x 4-Pin JST-XH:** I2C Display / Expansion (SDA, SCL, 3.3V, GND)

### Pin Headers (2.54mm Dupont)
- **4x 3-Pin Headers:** Jumper blocks for the "Flex Pins" (UART vs I2C vs Endstops)
- **1x 5-Pin Header:** Rotary Encoder (A, B, Push, VCC, GND)

---

## 2. Component Bill of Materials (BOM)

### Active Components (Silicon)
| Component | Part Number Recommendation | Function | Notes |
| :--- | :--- | :--- | :--- |
| **MCU** | STM32F401CCU6 | Main Processor | 48-Pin LQFP package |
| **Bed MOSFET** | WSK220N04 / WSK220N04-G | Heated Bed Control | High current, requires good thermal relief |
| **Hotend MOSFETs** | AOD4184A (x2) | Hotend Heater Control | Logic level gate |
| **Fan MOSFETs** | AO3400 (x3) | PWM Fan Control | SOT-23 package |
| **Buck Converter** | MP1584 / LM2596 | 12V/24V to 5V Step-down | Drives 5V rail for BLTouch & logic |
| **LDO Regulator** | AMS1117-3.3 | 5V to 3.3V Step-down | Powers the STM32 |

### Passive Components
| Component | Specification / Rating | Quantity | Function |
| :--- | :--- | :--- | :--- |
| **Electrolytic Capacitors** | 100uF / 35V | 5x | Bulk decoupling for Stepper Drivers (VMOT). Place right next to driver pins. |
| **Ceramic Capacitors** | 0.1uF / 50V | 10+ | Decoupling for STM32 VDD pins and logic rails |
| **Resistors (Pull-up)** | 4.7K Ω (1%) | 3x | ADC Pull-ups for the Thermistors (Critical for temp accuracy) |
| **Resistors (Pull-down)** | 100K Ω | 3x | Gate pull-downs for MOSFETs (Prevents heaters turning on during boot) |
| **Fuses (Automotive Blade)**| 15A | 1x | Heated Bed protection circuit |
| **Fuses (Automotive Blade)**| 10A | 1x | Stepper Motor & Logic protection circuit |

---

## 3. Stepper Driver Schematic Wiring (TMC2209)

When routing the StepStick headers for the stepper drivers, follow these specific wiring rules:

1. **VMOT vs VDD:** 
   - `VMOT` must be connected directly to the fused 12V/24V rail. 
   - `VDD` must be connected to the 3.3V logic rail (NOT 5V).
2. **Current Sense (Rsense):** Ensure the stepper driver sockets are grounded heavily to the internal GND plane for thermal dissipation.
3. **UART Multiplexing (The "Flex" Pins):**
   - Because `PA9` is shared as the UART bus for X, Y, Z, and E0 on the Standard/Pro models, connect `PA9` to the `PDN_UART` pin of all 4 driver sockets.
   - You MUST place a **1K Ω resistor** inline between `PA9` and the `PDN_UART` pin of each socket to prevent bus contention.
   - For hardware addressing, hardwire the MS1/MS2 pins under the driver sockets to achieve addresses 0, 1, 2, and 3:
     - Driver X (Addr 0): MS1=GND, MS2=GND
     - Driver Y (Addr 1): MS1=3.3V, MS2=GND
     - Driver Z (Addr 2): MS1=GND, MS2=3.3V
     - Driver E0 (Addr 3): MS1=3.3V, MS2=3.3V
