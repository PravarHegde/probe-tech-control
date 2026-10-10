<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
# Auro O Pro - Complete Hardware Assembly & Wiring Guide

This document is the master engineering blueprint for assembling the **Probharath Auro O Pro** (STM32F401, IDEX capable).

---

## 1. Complete Bill of Materials (BOM)

### A. Core Silicon & Computing
- **Microcontroller:** STM32F401CCU6 (Black Pill module or raw QFP-48 IC).
- **Stepper Drivers:** 5x TMC2209 v1.2 (or compatible StepStick modules).

### B. Power Regulation & Switching
- **Bed MOSFET:** 1x WSK220N04 (or IRLZ44N / IRFZ44N*). *Requires a heatsink!*
- **Hotend MOSFETs:** 2x AO3400 (or IRFZ44N*).
- **Fan MOSFETs:** 1x AO3400 (or IRFZ44N*).

> [!CAUTION]
> **IRFZ44N WARNING (*)**
> The IRFZ44N is a standard MOSFET, meaning it requires 10V on the gate to fully open. Your STM32 only outputs 3.3V! If you try to drive an IRFZ44N directly from a 3.3V pin to power a Heated Bed, it will only partially open, act like a massive resistor, and **rapidly overheat and catch fire**. 
> 
> *Solution:* To use your stock of IRFZ44N MOSFETs safely, you MUST use a small transistor or an optocoupler like the **PC817** to drive the IRFZ44N gate with 12V/24V, OR use a logic-level MOSFET instead like the **IRLZ44N**.

### 4.1 Heater Circuit using Logic-Level MOSFET (e.g. IRLZ44N, AO3400)
- **5V Logic Regulator:** 1x LM2596 (Buck Converter) or MP1584EN module (drops 24V PSU down to 5V for MCU and logic).
- **3.3V LDO:** 1x AMS1117-3.3 (drops 5V down to 3.3V for MCU core logic, if not using Black Pill).

### C. Connectors (Standardized to JST-XH)
- **Power Input:** 1x 2-pin High-Current Screw Terminal (Pitch 5.08mm or XT60).
- **Heated Bed Output:** 1x 2-pin High-Current Screw Terminal (Pitch 5.08mm).
- **Stepper Motors:** 5x JST-XH 2.54mm 4-Pin headers.
- **Hotend Heaters:** 2x JST-XH 2.54mm 2-Pin headers (or screw terminals).
- **Thermistors:** 3x JST-XH 2.54mm 2-Pin headers.
- **Endstops/Probe:** 3x JST-XH 2.54mm 3-Pin headers.
- **Fans:** 1x JST-XH 2.54mm 2-Pin header.
- **Display (I2C):** 1x JST-XH 2.54mm 4-Pin header.

### D. Passives (Resistors & Capacitors)
- **Capacitors:** 5x 100uF 35V Electrolytic (Decoupling capacitors, one placed across VMOT/GND for each stepper driver).
- **Pull-Up Resistors:** 5x 4.7K Ohm (For Thermistors and I2C lines).
- **Addressing Resistors:** 4x 10K Ohm (Used to pull MS1/MS2 pins high/low for UART addressing).
- **Gate Resistors:** 3x 100 Ohm (Between MCU and MOSFET gates).
- **Pull-Down Resistors:** 3x 10K Ohm (Between MOSFET gates and GND to prevent floating logic).

---

## 2. Text-Based Pin Diagram (STM32F401)

| Feature | Sub-Feature | STM32F401 Pin | Notes |
| :--- | :--- | :--- | :--- |
| **Stepper X** | STEP, DIR, EN | `PB13`, `PB14`, `PB12` | |
| **Stepper Y** | STEP, DIR, EN | `PB1`, `PB0`, `PB10` | |
| **Stepper Z** | STEP, DIR, EN | `PB3`, `PB4`, `PA15` | |
| **Stepper E0** | STEP, DIR, EN | `PA7`, `PB2`, `PA6` | |
| **Stepper E1** | STEP, DIR, EN | `PC14`, `PC15`, `PC13` | Standalone Mode (No UART) |
| **UART Bus** | TX/RX | `PA9` | Shared across X, Y, Z, E0 |
| **Heaters** | Bed, HE0, HE1 | `PB9`, `PB8`, `PA8` | |
| **Thermistors** | Bed, TH0, TH1 | `PA1`, `PA0`, `PA2` | Requires 4.7K Pull-Up |
| **Fans** | Both Hotend Fans | `PB7` | Hardwired to single port |
| **Display** | I2C SCL, SDA | `PB10`, `PB11` | Shared with Y-Enable (`PB10`)! *Warning: See note below.* |

> [!WARNING]
> **Pin Conflict Resolution:** In the Auro O architecture, `PB10` is heavily overloaded. PCB Layout engineers must use a hardware switch or trace-cut to disconnect the Y-Enable from `PB10` and move it to a free pin (like `PA5` or `PA4`) if the I2C display is used on the Pro.

---

## 3. Stepper Driver Connection Diagram (TMC2209)

The following schematic demonstrates how to wire the smart drivers on the **Shared UART Bus**, while wiring `E1` as a dumb standalone driver.

```text
[STM32F401 MCU]                      [TMC2209 - X AXIS]
      PB13 (STEP) ----------------------> STEP Pin
      PB14 (DIR)  ----------------------> DIR Pin
      PB12 (EN)   ----------------------> EN Pin
      PA9 (UART)  --------[1K Res]------> UART (TX/RX) Pin (Address 00 via MS1/MS2 = GND)

[STM32F401 MCU]                      [TMC2209 - Y AXIS]
      PB1 (STEP)  ----------------------> STEP Pin
      PB0 (DIR)   ----------------------> DIR Pin
      PB10 (EN)   ----------------------> EN Pin
      PA9 (UART)  --------[1K Res]------> UART (TX/RX) Pin (Address 01 via MS1=VCC, MS2=GND)

[STM32F401 MCU]                      [TMC2209 - Z AXIS]
      PB3 (STEP)  ----------------------> STEP Pin
      PB4 (DIR)   ----------------------> DIR Pin
      PA15 (EN)   ----------------------> EN Pin
      PA9 (UART)  --------[1K Res]------> UART (TX/RX) Pin (Address 10 via MS1=GND, MS2=VCC)

[STM32F401 MCU]                      [TMC2209 - E0 AXIS]
      PA7 (STEP)  ----------------------> STEP Pin
      PB2 (DIR)   ----------------------> DIR Pin
      PA6 (EN)    ----------------------> EN Pin
      PA9 (UART)  --------[1K Res]------> UART (TX/RX) Pin (Address 11 via MS1/MS2 = VCC)

[STM32F401 MCU]                      [TMC2209 - E1 AXIS] (PRO ONLY)
      PC14 (STEP) ----------------------> STEP Pin
      PC15 (DIR)  ----------------------> DIR Pin
      PC13 (EN)   ----------------------> EN Pin
     (NO UART)    ----------------------> UART Pin is left completely disconnected!
                                          (VREF is set manually via potentiometer)
```

### 3.1 Legacy Support: Using A4988 or DRV8825

Because the Auro O Pro shares a physical PCB with the **Auro O Standard**, you might want to install cheap A4988 or DRV8825 standalone drivers instead of TMC2209s.

**The UART Pin Conflict (MS3):**
On a TMC2209, the 4th pin down is the **UART** pin. But on an A4988 or DRV8825, that exact same pin is the **MS3** (Microstep 3) pin! 
If the STM32's `PA9` (UART) pin is permanently hardwired to `MS3`, it can cause random microstepping changes if the MCU sends UART signals or leaves the pin floating.

**The Jumper Solution (MS1, MS2, MS3):**
To make the board universally compatible, the PCB must use **3-pin jumper blocks** for `MS1`, `MS2`, and `MS3` under every driver socket:

1. **MS3 / UART Jumper:**
   - **TMC2209 (Smart):** Jumper connects Driver Pin to MCU `PA9` (UART).
   - **A4988 (Standalone):** Jumper connects Driver Pin to `VCC`.
   
2. **MS1 and MS2 Jumpers (Addressing vs Microstepping):**
   - **TMC2209 (Smart):** The jumpers are used to set the UART address. 
     - X Axis: `MS1`=GND, `MS2`=GND (Address 00)
     - Y Axis: `MS1`=VCC, `MS2`=GND (Address 01)
     - Z Axis: `MS1`=GND, `MS2`=VCC (Address 10)
     - E0 Axis: `MS1`=VCC, `MS2`=VCC (Address 11)
   - **A4988 (Standalone):** The jumpers are used to set microstepping. To get the smoothest 1/16th microstepping, simply bridge **all** `MS1` and `MS2` jumpers to `VCC` on every axis!

---

## 4. Heater & MOSFET Connection Diagram

Directly driving a heater from a 3.3V microcontroller will destroy the chip. You must use an N-Channel MOSFET with proper gate resistors.

```text
                                       +24V Power Supply
                                              |
                                              |
                                      [Heater Cartridge]
                                              |
                                              |
                            Drain (D) --------+
                              |
                        [N-Channel MOSFET] (e.g. AO3400)
                              |
[STM32F401]                   | Source (S)
  Pin PB8  ----[100 Ohm]---- Gate (G)         |
  (3.3V PWM)        |                         |
                    |                         |
                [10K Ohm]                     |
                    |                         |
                   GND                       GND
```

**How it works:**
1. The MCU sends a 3.3V PWM signal from `PB8` through a 100 Ohm resistor (limits current rush to the gate capacitance).
2. The MOSFET turns "ON", allowing 24V current to flow from the power supply, through the heater, and into the Drain (D).
3. The 10K pull-down resistor ensures the MOSFET stays firmly "OFF" while the MCU is booting up, preventing thermal runaway.

### 4.2 Heater Circuit using Standard MOSFET (e.g. IRFZ44N) + PC817 Optocoupler

Because the IRFZ44N requires ~10V to fully open, we use a PC817 optocoupler to step the 3.3V logic up to 24V (or 12V).

```text
[STM32F401]                   [PC817 Optocoupler]
  Pin PB8  ----[220 Ohm]---- (1) Anode       Collector (4) -------+------- +24V Supply
  (3.3V)                                                          |
                                                              [1K Ohm Pull-Up]
                   GND ----- (2) Cathode       Emitter (3)        |
                                                    |             |
                                                    |             +--- Gate (G) [IRFZ44N]
                                                    |             |
                                                    +-------------+
                                                    |
                                                 [10K Ohm Pull-Down]
                                                    |
                                                   GND
```

**How it works:**
1. The STM32 sends a 3.3V PWM signal to the PC817's internal LED (limited by a 220 Ohm resistor).
2. The LED turns on, activating the internal phototransistor.
3. The phototransistor conducts 24V directly into the Gate of the IRFZ44N.
4. The IRFZ44N is now receiving 24V at its gate, meaning it is **100% fully open**, resulting in zero heat generation at the MOSFET!
