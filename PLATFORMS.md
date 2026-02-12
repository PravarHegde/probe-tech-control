# Multi-Platform Support - Windows & macOS

While Probe Tech Control runs on **Windows** and **macOS** via Docker, the primary challenge is **USB Passthrough** (allowing the Klipper container to talk to your physical 3D printer).

---

## 🪟 Windows Setup (WSL2)

Windows doesn't natively expose USB ports to Docker. Use **usbipd-win** to share your printer.

### 1. Prerequisites
- **Docker Desktop** (configured with WSL2 Backend).
- **Git Bash** or **Ubuntu (WSL2)** from the Microsoft Store.

### 2. USB Passthrough
1. Install [usbipd-win](https://github.com/dorssel/usbipd-win).
2. Open PowerShell as Admin and find your printer:
   ```powershell
   usbipd list
   ```
3. Attach the printer to WSL:
   ```powershell
   usbipd bind --busid <BUSID>
   usbipd attach --wsl --busid <BUSID>
   ```

### 3. Running PTC
Open your **WSL2 Terminal** (Ubuntu) or **Git Bash** and run:
```bash
./docker-install.sh
```
*Note: The script might show errors for `/proc` and `/sys` mounts. These can be safely ignored on Windows as they are handled by WSL2.*

---

## 🍎 macOS Setup (Colima)

Standard Docker Desktop on Mac has very limited USB support. We recommend **Colima** for hardware access.

### 1. Prerequisites
- **Homebrew** installed.
- **Colima** and **Docker client**:
  ```bash
  brew install colima docker docker-compose
  ```

### 2. Start Colima with USB Support
Launch the VM with the serial devices exposed:
```bash
colima start --cpu 2 --memory 4 --disk 20
```

### 3. Running PTC
In your Mac terminal:
```bash
./docker-install.sh
```

---

## ⚠️ Important Considerations
- **Serial Paths**: On Windows/Mac, the printer might show up as `/dev/ttyUSB0` or `/dev/ttyACM0` inside the container once attached. Ensure your `printer.cfg` matches this.
- **Performance**: Docker on Windows/Mac runs inside a Virtual Machine. Performance is slightly lower than native Linux but more than sufficient for 3D printing.
