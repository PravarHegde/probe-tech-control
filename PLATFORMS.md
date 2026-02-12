## 🪟 Windows Setup (WSL2)

Windows doesn't natively expose USB ports to Docker. The "magic helper" tool you need is **usbipd-win**.

### 1. The "Seamless" Helper: usbipd-win
This is the essential plugin/tool that bridges your Windows USB port to the Linux/Docker environment.
- **Download**: [usbipd-win Releases](https://github.com/dorssel/usbipd-win/releases)
- **Install**: Run the `.msi` or use `winget install dorssel.usbipd-win`.

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

## 🤖 Android Setup (Old Smartphones)

Repurposing an old Android phone is one of the most cost-effective ways to run Klipper and PTC.

### 1. Hardware Requirements
- **USB OTG Adapter**: To connect the phone to the printer's USB cable.
- **Power Y-Cable**: Highly recommended. This allows you to charge the phone while it's connected to the printer.
- **Android Version**: 5.0 (Lollipop) or higher.

### 2. Method A: Octo4a (Easiest)
[Octo4a](https://github.com/feelfreelinux/octo4a) is an all-in-one app that handles the Linux environment and USB drivers.
1. Install the **Octo4a APK** on your phone.
2. Open Octo4a and go to **Extensions**.
3. Install the **Klipper Extension**.
4. In the Klipper settings inside Octo4a, ensure the serial port is set to `/dev/ttyOcto4a`.
5. Note the **IP Address** shown on the Octo4a screen.

### 3. Method B: Termux (Advanced)
For users comfortable with the command line.
1. Install **Termux** from F-Droid.
2. Use a script like [KIAUH](https://github.com/dw-0/kiauh) inside a `proot` Debian environment to install Klipper and Moonraker.

---

### 4. Connecting PTC to your Phone
Once Klipper/Moonraker is running on your phone:
1. Open Probe Tech Control on your PC/Tablet.
2. Go to **Settings > Connectivity**.
3. Enter your phone's IP address (e.g., `192.168.1.50`) and port `7125`.
4. Your old phone is now the "brain" of your printer!

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
