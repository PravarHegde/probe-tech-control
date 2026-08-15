<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Probharath Auro O Standard

The **Standard** is the entry-level configuration of the Auro O series, prioritizing offline control and maximum cost-efficiency.

## Key Features
- **Drivers:** 5x Standalone Drivers (A4988 / DRV8825).
- **UART:** None. (Drivers are tuned manually via potentiometer).
- **Extruders:** Single Nozzle.
- **Display:** Full Support! Features an I2C OLED/LCD header (`PB10` & `PB11`) and a 3-pin rotary encoder header (`PA8`, `PA9`, `PB5`).

## Why choose the Standard?
Because this configuration does not use UART data lines, it frees up 5 critical pins on the microcontroller. This makes it the perfect configuration if you want to use cheap standalone stepper drivers and control your printer completely offline via an attached screen and knob.
