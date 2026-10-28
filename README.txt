One UI 8.5 for Redmi Pad Pro 5G / POCO Pad 5G (ruan) - v1.6-b30-20261028

Requirements: unlocked bootloader, battery above 50%, USB-C data cable.
Windows: Xiaomi/Google USB driver. Linux/macOS: Android platform-tools (fastboot) in PATH.

1. Power off the tablet, hold Volume Down + Power until FASTBOOT shows, connect it to the PC.
2. First install (ERASES ALL DATA): run install.bat (Windows) or ./install.sh (Linux/macOS).
   Update from an earlier release (keeps data): run update.bat or ./update.sh.
3. Wait for the tablet to reboot by itself. The first boot takes up to 10 minutes.
   Apps are optimised automatically about 2 minutes after the first boot (the tablet may feel busy for a while).

Root: Magisk is built in (Magisk-patched Caramel boot) and the Magisk app is preinstalled.
Open Magisk once after the first boot and let it finish any setup it asks for.

Do not lock the bootloader on this ROM. To go back: flash the stock HyperOS fastboot ROM.
