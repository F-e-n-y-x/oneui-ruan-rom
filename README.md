# One UI 8.5 for Redmi Pad Pro 5G: fastboot ROM (v1.6-b30-20261028)

Flashable fastboot package for the **Redmi Pad Pro 5G / POCO Pad 5G (`ruan`)**: Samsung One UI 8.5 (Galaxy Tab S9 5G) on the stock
HyperOS vendor, with Magisk root. Source, status and known limitations: [oneui-ruan](https://github.com/F-e-n-y-x/oneui-ruan).

## Download
```
git clone --depth 1 https://github.com/F-e-n-y-x/oneui-ruan-rom.git
```
(about 7 GB). Large images are stored in 95 MB parts; the install/update scripts join and verify them the first time you run them.

## Install
Requirements: unlocked bootloader, battery above 50%, USB-C data cable. Windows: Xiaomi/Google USB driver. Linux/macOS:
Android platform-tools (`fastboot`) in PATH.

1. Power off the tablet, hold **Volume Down + Power** until **FASTBOOT** shows, connect it to the PC.
2. **First install (erases all data):** `install.bat` (Windows) or `./install.sh` (Linux/macOS).
   **Update from an earlier release (keeps data):** `update.bat` or `./update.sh`.
3. The tablet reboots by itself. The first boot takes up to 10 minutes.

Root: Magisk is built in. Never re-lock the bootloader on this ROM; to go back, flash the stock HyperOS fastboot ROM.

To update this folder to a newer release: `git fetch --depth 1 && git reset --hard origin/main` (only the latest ROM is kept).
