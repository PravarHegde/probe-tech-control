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

## 🤖 Android Setup (Octo4a / Termux)

You can repurpose an old Android phone as a Klipper host for PTC.

### 1. Recommended: Octo4a + Klipper Extension
- **Pros**: Handles USB-OTG connectivity automatically; no root needed.
- **Setup**: Install [Octo4a](https://github.com/feelfreelinux/octo4a), enabling the Klipper extension.
- **Connection**: In PTC, connect to the IP of your phone on port 7125.

### 2. Advanced: Termux (Proot Debian)
- Setup a full Linux environment using **KIAUH** inside Termux. 
- Best for users who want a native Linux experience on Android.

---

## ⚖️ PTC vs. OctoPrint

| Feature | Probe Tech Control (PTC) | OctoPrint |
| :--- | :--- | :--- |
| **Engine** | Klipper + Moonraker | OctoPrint Core |
| **UI Type** | Modern, SPA, Lightweight | Plugin-based, Traditional |
| **Resource Usage**| Very Low (Docker Optimized) | Moderate to High |
| **Windows Support**| WSL2 + Docker | Native Python or Docker |
| **Android** | Via Termux or Octo4a | Native via Octo4a |

**Summary**: PTC provides a faster, more modern interface for Klipper users compared to the heavier plugin architecture of OctoPrint.
