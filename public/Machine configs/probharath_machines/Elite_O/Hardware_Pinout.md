<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Elite O - Hardware PCB Pinout Matrix (STM32F401 Edition)

This document maps the **STM32F401 (48-pin)** for the Probharath Elite O. 

Because the STM32F401 only has 35 usable GPIO pins, packing in premium features (5 Steppers, Dual Extrusion, NeoPixel, I2C, and WiFi) requires clever PCB design using **User Selection Jumper Headers**. 

---

## 1. Core Stepper Motors
As per the Auro architecture, the primary extruder (E0) gets a **dedicated UART pin** for uninterrupted data flow, while the remaining drivers (X, Y, Z, and E1) share a **UART Bus (`PA9`)**. PCB designers must hardwire the `MS1` and `MS2` pins for the shared drivers to give them unique addresses.

| Axis | STEP | DIR | ENABLE | UART | Addressing (MS1/MS2) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **X** | `PB13` | `PB14`| `PB12` | `PA9` (Shared) | Address 0 (0,0) |
| **Y** | `PB1` | `PB0` | `PB10` | `PA9` (Shared) | Address 1 (1,0) |
| **Z** | `PB3` | `PB4` | `PA15` | `PA9` (Shared) | Address 2 (0,1) |
| **E0** | `PA7` | `PB2` | `PA6` | **`PB15` (Dedicated)** | N/A |
| **E1** | `PC14` | `PC15`| `PC13` | `PA9` (Shared) | Address 3 (1,1) |

---

## 2. Jumper Block A: E1 (5th Stepper) vs. Expansion
The remaining 3 pins (`PC13`, `PC14`, `PC15`) are routed to a multiplexing jumper block. The user can either use them for a 5th Stepper Driver (E1) OR for Expansion headers.

| User Jumper Setting | Pin `PC14` | Pin `PC15` | Pin `PC13` |
| :--- | :--- | :--- | :--- |
| **Mode: Dual Extrusion**| E1 STEP | E1 DIR | E1 ENABLE |
| **Mode: Expansion** | NeoPixel RGB | I2C SDA (`PB11` override)| I2C SCL (`PB10` override) |

---

## 3. Jumper Block B: Sensorless vs. Physical Endstops
To save pins, the user selects if they want physical endstop switches OR if they want to route the DIAG pins to the MCU for Sensorless Homing (StallGuard).

| User Jumper Setting | Pin `PA2` | Pin `PA3` | Pin `PA10` |
| :--- | :--- | :--- | :--- |
| **Mode: Physical Switches**| X Endstop | Y Endstop | Z Endstop |
| **Mode: Sensorless Homing**| X DIAG | Y DIAG | Z DIAG |

---

## 4. Jumper Block C: WiFi UART vs Dual Hotends
The `PA8` and `PB5` pins can be used for a 2nd Hotend OR an ESP32 WiFi Module.

| User Jumper Setting | Pin `PA8` | Pin `PB5` |
| :--- | :--- | :--- |
| **Mode: Dual Hotends**| Heater 1 (MOSFET) | Thermistor 1 (ADC) |
| **Mode: WiFi UART** | ESP TX (`USART1_TX`) | ESP RX (`USART1_RX`) |

---

## 5. Core Heaters & Fans
| Function | Pin | Notes |
| :--- | :--- | :--- |
| **Bed Heater** | `PB9` | Requires high-current MOSFET |
| **Heater 0** | `PB8` | Requires MOSFET |
| **Bed Thermistor** | `PA1` | Requires 4.7K Pull-up (ADC) |
| **Thermistor 0** | `PA0` | Requires 4.7K Pull-up (ADC) |
| **Part Cooling Fan** | `PB7` | PWM capable |
| **Hotend Fan** | `PB6` | PWM capable |

---

## 6. Probe / BLTouch
| Function | Pin | Notes |
| :--- | :--- | :--- |
| **Probe Sensor** | `PA4` | |
| **Probe Control (Servo)** | `PA5` | Hardware PWM |
