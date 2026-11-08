@echo off
:: Downloads the release in release.txt and runs its install script (see README).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\rom.ps1" install
if errorlevel 1 pause
