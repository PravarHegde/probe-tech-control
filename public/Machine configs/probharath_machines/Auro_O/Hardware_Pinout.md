<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Auro O - Hardware PCB Pinout Matrix

This document is for PCB Layout Engineers. It maps the 35 usable GPIO pins of the 48-pin **STM32F401CCU6** (or similar F401/F411 packages) to their respective hardware functions across all 4 Auro O configurations.

Because all 4 SKUs are based on the **same physical PCB**, the traces should be routed according to this master matrix. Configuration-specific changes (like using a pin for I2C vs UART) will be handled via software or physical jumper caps on the board.

## Stepper Motor Control (15 Pins - Identical across all boards)
| Function | X Stepper | Y Stepper | Z Stepper | Extruder 0 | Extruder 1 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **STEP** | `PB13` | `PB1` | `PB3` | `PA7` | `PC14` |
| **DIR** | `PB14` | `PB0` | `PB4` | `PB2` | `PC15` |
| **ENABLE** | `PB12` | `PB10` *(Pro uses `PA10`)* | `PA15` | `PA6` | `PC13` |

---

## The "Flex" Pins (The Multiplexed Features)
These pins change their hardware function depending on which of the 4 configurations the user flashes. **When designing the PCB, route these pins to jumper headers so the user can physically select the routing.**

| Pin | Auro O Light (Standalone) | Auro O Standard (Shared UART) | Auro O Pure (Dedicated UART) | Auro O Pro (Dual Nozzle) |
| :--- | :--- | :--- | :--- | :--- |
| **`PA9`** | Encoder Pin A | **Shared UART** (X, Y, Z, E0) | `E1` UART | **Shared UART** (X, Y, Z, E0) |
| **`PB15`** | *Unused* | *Unused* | `X` UART | *Unused* |
| **`PB11`** | I2C SDA (Display) | I2C SDA (Display) | `Y` UART | I2C SDA (Display) |
| **`PB5`** | Encoder Push Button | Navigation Button | `Z` UART | `X` Endstop |
| **`PA8`** | Encoder Pin B | Navigation Button | `E0` UART | Heater 1 (2nd Nozzle) |
| **`PA2`** | `X` Endstop | `X` Endstop | `X` Endstop | Thermistor 1 (2nd Nozzle) |
| **`PA10`**| *Unused* | *Unused* | *Unused* | `Y` Enable (Moved from PB10) |
| **`PB10`**| I2C SCL (Display) | I2C SCL (Display) | `Y` Enable | I2C SCL (Display) |

---

## Modular Expansion Headers
To support user-selectable hardware upgrades (as requested for future updates), the following expansion interfaces should be broken out on the PCB using standard JST-XH or Dupont headers.

| Expansion Type | Pins | Notes |
| :--- | :--- | :--- |
| **I2C Expansion (4-pin)** | `PB10` (SCL), `PB11` (SDA), 3.3V, GND | Used for OLED displays, I2C filament sensors. Standard on all models except Pure. <br>*(**Alternative:** Can be repurposed as `USART3` (TX/RX) for WiFi if a display is not used).* |
| **SPI Expansion (6-pin)** | `PA5` (SCK), `PA6` (MISO), `PA7` (MOSI), `PB12` (CS), 3.3V, GND | Used for ADXL345 input shaping. (Note: Shares pins with E0/Probe, requires jumper selection). |
| **Raw GPIO (3-pin)** | `PC15` (Signal), 5V, GND | Available if Extruder 1 is unused. Can drive WS2812 RGB LEDs or Relays. |
| **WiFi UART (4-pin)** | `PA2` (TX), `PA3` (RX), 5V/3.3V, GND | Used for ESP8266/ESP32 WiFi modules. Available ONLY if using Sensorless Homing (which frees up the X/Y physical endstops). |

---

> **Note:** The Auro O is a 48-pin MCU pushed to its absolute limit. Enabling SPI or Raw GPIO expansions requires disabling the conflicting hardware feature (e.g., E0/E1) via jumper blocks.

## Heaters & Thermistors
| Function | Pin | Notes |
| :--- | :--- | :--- |
| **Bed Heater** | `PB9` | Requires high-current MOSFET |
| **Heater 0** | `PB8` | Requires MOSFET |
| **Heater 1** | `PA8` | Requires MOSFET *(Used only in Pro)* |
| **Bed Thermistor** | `PA1` | Requires 4.7K Pull-up (ADC) |
| **Thermistor 0** | `PA0` | Requires 4.7K Pull-up (ADC) |
| **Thermistor 1** | `PA2` | Requires 4.7K Pull-up (ADC) *(Used only in Pro)* |

---

## Fans & Endstops
| Function | Pin | Notes |
| :--- | :--- | :--- |
| **Part Cooling Fan** | `PB7` | PWM capable |
| **Hotend Fan(s)** | `PB6` | *(Pro wires both hotends to this single pin)* |
| **X Endstop** | `PA2` | *(Moved to `PB5` on the Pro model)* |
| **Y Endstop** | `PA3` | |
| **Z Endstop (Probe Sensor)** | `PA4` | |
| **Probe Control (Servo)** | `PA5` | |

---

## PCB Design Guidelines for the "Flex" Pins
Because `PA9`, `PB11`, `PB5`, and `PA8` serve entirely different purposes depending on the model, you must use **Jumper Blocks** on the physical PCB. 

For example, for pin `PB11`:
- Add a 3-pin jumper block.
- **Center pin:** Routed directly to the MCU `PB11`.
- **Left pin:** Routed to the I2C SDA header.
- **Right pin:** Routed to the TMC `Y` UART pin.
- *The user will simply move a plastic jumper cap to select whether they want the Pure config or the Standard/Pro configs.*
