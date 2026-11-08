@echo off
:: Downloads the release in release.txt and runs its update script (see README).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\rom.ps1" update
if errorlevel 1 pause
