#!/usr/bin/env python3
"""
==============================================================================
PROBHARATH TECHNOLOGIES - ULTRA-RELIABLE POWER LOSS RECOVERY ENGINE (PLR)
Accurately slices and resumes G-code from exact interrupted Z height.
Compatible with Cura, PrusaSlicer, OrcaSlicer, Bambu Studio & SuperSlicer.
==============================================================================
"""

import sys
import os
import re
import configparser

def get_variable(var_name, config_path="/home/probharath/printer_data/config/variables.cfg"):
    if not os.path.exists(config_path):
        return None
    try:
        config = configparser.ConfigParser()
        config.read(config_path)
        if "Variables" in config and var_name in config["Variables"]:
            val = config["Variables"][var_name]
            return val.strip("'\"")
    except Exception as e:
        print(f"Error reading variables.cfg: {e}")
    return None

def main():
    target_z_arg = sys.argv[1] if len(sys.argv) > 1 else None
    filename_arg = sys.argv[2] if len(sys.argv) > 2 else None

    # Resolve filename
    last_file = filename_arg or get_variable("last_file")
    if not last_file:
        print("ERROR: No file specified for Power Loss Recovery.")
        sys.exit(1)

    # Resolve target Z
    try:
        target_z = float(target_z_arg) if target_z_arg else float(get_variable("power_resume_z", "0"))
    except ValueError:
        print(f"ERROR: Invalid target Z height: {target_z_arg}")
        sys.exit(1)

    # Resolve input file path
    filepath = get_variable("filepath")
    if not filepath or not os.path.exists(filepath):
        # Fallback to standard gcodes directory
        filepath = os.path.join("/home/probharath/printer_data/gcodes", last_file)

    if not os.path.exists(filepath):
        print(f"ERROR: Gcode file not found at {filepath}")
        sys.exit(1)

    # Destination directory & file
    out_dir = "/home/probharath/printer_data/gcodes/plr"
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, os.path.basename(last_file))

    print(f"=== ProBharath PLR: Processing {filepath} for Resume at Z={target_z}mm ===")

    bed_temp = "60"
    hotend_temp = "200"
    fan_speed = "204"
    is_relative_extrusion = False
    
    last_e = 0.0
    last_x = None
    last_y = None
    resume_index = -1

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    # Pass 1: Scan for temps, extrusion mode, and find resume line
    for i, line in enumerate(lines):
        clean = line.split(";")[0].strip()
        
        # Bed temp
        m_bed = re.search(r"(?:M140|M190)\s+S([0-9\.]+)", clean)
        if m_bed:
            bed_temp = m_bed.group(1)

        # Hotend temp
        m_hot = re.search(r"(?:M104|M109)\s+S([0-9\.]+)", clean)
        if m_hot:
            hotend_temp = m_hot.group(1)

        # Fan speed
        m_fan = re.search(r"M106\s+S([0-9]+)", clean)
        if m_fan:
            fan_speed = m_fan.group(1)

        # Relative extrusion
        if "M83" in clean:
            is_relative_extrusion = True
        elif "M82" in clean:
            is_relative_extrusion = False

        # Track previous coordinates before target Z
        if resume_index == -1:
            m_e = re.search(r"[^A-Za-z]E(-?[0-9\.]+)", clean)
            if m_e:
                try:
                    last_e = float(m_e.group(1))
                except ValueError:
                    pass

            m_x = re.search(r"[^A-Za-z]X([0-9\.]+)", clean)
            if m_x:
                last_x = m_x.group(1)

            m_y = re.search(r"[^A-Za-z]Y([0-9\.]+)", clean)
            if m_y:
                last_y = m_y.group(1)

            # Check if this line is the Z height transition
            m_z = re.search(r"[^A-Za-z]Z([0-9\.]+)", clean)
            if m_z:
                try:
                    cur_z = float(m_z.group(1))
                    # Allow slight float margin of 0.005mm
                    if cur_z >= (target_z - 0.005):
                        resume_index = i
                except ValueError:
                    pass

    if resume_index == -1:
        print(f"WARNING: Could not find layer with Z >= {target_z}mm. Defaulting to end.")
        resume_index = len(lines) - 1

    print(f"Resume cut line: {resume_index} (out of {len(lines)})")
    print(f"Extracted Settings: Bed={bed_temp}C, Hotend={hotend_temp}C, Fan={fan_speed}, E={last_e}")

    # Write output recovery G-code
    with open(out_path, "w", encoding="utf-8") as out:
        out.write("; ==============================================================================\n")
        out.write(f"; PROBHARATH POWER LOSS RECOVERY RESUME FILE\n")
        out.write(f"; Original File: {last_file}\n")
        out.write(f"; Target Z: {target_z}mm (Cut at line {resume_index})\n")
        out.write("; ==============================================================================\n")
        out.write(f"SET_KINEMATIC_POSITION Z={target_z}\n")
        out.write(f"M118 ⚡ Heating Bed to {bed_temp}C and Nozzle to {hotend_temp}C...\n")
        out.write(f"M140 S{bed_temp}\n")
        out.write(f"M104 S{hotend_temp}\n")
        out.write(f"M190 S{bed_temp}\n")
        out.write(f"M109 S{hotend_temp}\n\n")
        
        out.write("; Safe clearance move (Lift Z 5mm above the print)\n")
        out.write("G91\n")
        out.write("G1 Z5 F600\n")
        out.write("G90\n\n")

        out.write("; Home X and Y ONLY (Never home Z into the printed part)\n")
        out.write("G28 X Y\n\n")

        out.write(f"; Restore Part Fan\n")
        out.write(f"M106 S{fan_speed}\n\n")

        out.write("; Restore Extruder Coordinate State\n")
        if is_relative_extrusion:
            out.write("M83 ; Relative extrusion\n")
            out.write("G92 E0\n")
        else:
            out.write("M82 ; Absolute extrusion\n")
            out.write(f"G92 E{last_e}\n")

        # If we know where the toolhead was printing, navigate there before descending
        if last_x and last_y:
            out.write(f"G1 X{last_x} Y{last_y} F3000 ; Move above resume XY\n")
            out.write(f"G1 Z{target_z} F600 ; Descend to print layer\n")

        out.write("M118 🚀 Resuming G-Code Stream...\n")
        out.write("; === RESUMED GCODE STREAM ===\n")

        # Stream all remaining lines
        for j in range(resume_index, len(lines)):
            out.write(lines[j])

    print(f"SUCCESS: Recovery G-code written to {out_path} ({os.path.getsize(out_path)} bytes)")

if __name__ == "__main__":
    main()
