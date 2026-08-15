<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Probharath Auro O Series

The **Probharath Auro O** is an ultra-budget, highly efficient 3D printer motherboard based on the 48-pin STM32F401 microcontroller. 

By carefully mapping and optimizing the incredibly tight 35-pin GPIO limit of this processor, we have developed four distinct product configurations (SKUs) based on the exact same underlying hardware. This allows you to choose the exact trade-offs that best suit your machine!

## The Lineup

### 1. Auro O Lite (`Lite/`)
Designed for absolute cost savings. It runs all stepper drivers in standalone mode (no UART), completely freeing up the data pins so you can easily attach an I2C Display and a Rotary Encoder. 

### 2. Auro O Standard (`Standard/`)
The sweet spot. Uses smart TMC drivers sharing a single UART bus. This provides smart motor control while still retaining enough free pins for an I2C Display and simple navigation buttons.

### 3. Auro O Pure (`Pure/`)
For the performance purist. It allocates a dedicated UART pin to every single stepper driver. This provides maximum, collision-free communication bandwidth, but consumes all available pins, leaving no room for a screen.

### 4. Auro O Pro (`Pro/`)
The dual-extrusion powerhouse. It uses a shared UART bus to save pins, but instead of adding a screen, it spends those extra pins on a second hotend heater, a second thermistor, and a second hotend fan to create a full IDEX capable machine!

---
*Navigate to each respective folder to find the `printer.cfg` ready to flash to your machine.*
