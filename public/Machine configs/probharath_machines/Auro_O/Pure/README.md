<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Probharath Auro O Pure

The **Pure** configuration is designed for users who want maximum, uncompromised performance from their TMC drivers.

## Key Features
- **Drivers:** 5x Smart TMC Drivers (TMC2208 / TMC2209).
- **UART:** 100% Dedicated. Every single driver gets its own, unshared data pin.
- **Extruders:** Single Nozzle.
- **Display:** None (Headless).

## Why choose the Pure?
Sharing a UART bus means data has to be sent sequentially. The Pure configuration gives every single driver a dedicated line, guaranteeing maximum bandwidth and preventing a single broken trace from bringing down the whole bus. The trade-off is that it consumes every single free pin on the 48-pin microcontroller, leaving no room for a screen. This configuration is meant to be run completely headless via the Probe Tech Control web UI.
