<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Probharath Auro O Pro

The **Pro** pushes the tiny 48-pin STM32F401 microcontroller to its absolute physical limits, cramming in support for Dual Extruders (IDEX).

## Key Features
- **Drivers:** 5x Smart TMC Drivers (TMC2208 / TMC2209).
- **UART:** Shared Bus. (Extruder 1 is run in standalone mode).
- **Extruders:** DUAL Nozzle (IDEX Capable).
- **Display:** Full Support! (I2C header mapped to `PB10` & `PB11`).

## Why choose the Pro?
This is an engineering marvel for a budget board. By sharing the UART bus, wiring both hotend cooling fans to a single port, and putting the second extruder in standalone mode, we freed up the exact number of pins required to add a 2nd Hotend Heater, a 2nd Thermistor, *and* an I2C display header. It transforms a budget board into an IDEX powerhouse.

> **Note: Using the Pro as a Standard Single-Extruder Board**
> Because the hardware is identical, you can easily use the Pro configuration for a standard single-extruder machine. If you don't need a 2nd Hotend, simply plug your two fans into the independent fan ports (instead of splicing them) and comment out the 2nd extruder block in the `printer.cfg`.
