@echo off
:: One UI 8.5 for Redmi Pad Pro 5G (ruan) v1.6-b30-20261028: update, keeps data
cd /d "%~dp0"
:: Join the split images (git stores files up to 100 MB), once, then verify them.
if not exist images\NON-HLOS.bin copy /b images\NON-HLOS.bin.part000+images\NON-HLOS.bin.part001+images\NON-HLOS.bin.part002+images\NON-HLOS.bin.part003 images\NON-HLOS.bin >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\NON-HLOS.bin).Hash -ne '3B3B3277C0A40C30EEA746577FD0B4C44AC253AED8401E4FBA8FD94ED88BA034'){exit 1}" || (echo images\NON-HLOS.bin is corrupt: delete it and run again & pause & exit /B 1)
if not exist images\boot.img copy /b images\boot.img.part000+images\boot.img.part001 images\boot.img >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\boot.img).Hash -ne '08E34FE05AE793C021ABC4AB798C19D056AC191D3EEE1529B35DC7D0E41D31E2'){exit 1}" || (echo images\boot.img is corrupt: delete it and run again & pause & exit /B 1)
if not exist images\recovery.img copy /b images\recovery.img.part000+images\recovery.img.part001 images\recovery.img >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\recovery.img).Hash -ne '8C2C34E653DBF68669E619B8616885D2997EC9762FBC32FC4008A4278D87F760'){exit 1}" || (echo images\recovery.img is corrupt: delete it and run again & pause & exit /B 1)
if not exist images\super.img copy /b images\super.img.part000+images\super.img.part001+images\super.img.part002+images\super.img.part003+images\super.img.part004+images\super.img.part005+images\super.img.part006+images\super.img.part007+images\super.img.part008+images\super.img.part009+images\super.img.part010+images\super.img.part011+images\super.img.part012+images\super.img.part013+images\super.img.part014+images\super.img.part015+images\super.img.part016+images\super.img.part017+images\super.img.part018+images\super.img.part019+images\super.img.part020+images\super.img.part021+images\super.img.part022+images\super.img.part023+images\super.img.part024+images\super.img.part025+images\super.img.part026+images\super.img.part027+images\super.img.part028+images\super.img.part029+images\super.img.part030+images\super.img.part031+images\super.img.part032+images\super.img.part033+images\super.img.part034+images\super.img.part035+images\super.img.part036+images\super.img.part037+images\super.img.part038+images\super.img.part039+images\super.img.part040+images\super.img.part041+images\super.img.part042+images\super.img.part043+images\super.img.part044+images\super.img.part045+images\super.img.part046+images\super.img.part047+images\super.img.part048+images\super.img.part049+images\super.img.part050+images\super.img.part051+images\super.img.part052+images\super.img.part053+images\super.img.part054+images\super.img.part055+images\super.img.part056+images\super.img.part057+images\super.img.part058+images\super.img.part059+images\super.img.part060+images\super.img.part061+images\super.img.part062+images\super.img.part063+images\super.img.part064+images\super.img.part065+images\super.img.part066+images\super.img.part067+images\super.img.part068+images\super.img.part069 images\super.img >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\super.img).Hash -ne '1FE44761CC8289B74B6FD7E478C76860C881A0E05E4FDF6B57C0AD470DD07E1E'){exit 1}" || (echo images\super.img is corrupt: delete it and run again & pause & exit /B 1)
if not exist images\userdata.img copy /b images\userdata.img.part000+images\userdata.img.part001+images\userdata.img.part002 images\userdata.img >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\userdata.img).Hash -ne 'DB3EAC017D4D66A958E2FC330C39E54E0737417D904ED967D80244376429BDCD'){exit 1}" || (echo images\userdata.img is corrupt: delete it and run again & pause & exit /B 1)
if not exist images\vendor_boot.img copy /b images\vendor_boot.img.part000+images\vendor_boot.img.part001 images\vendor_boot.img >nul || exit /B 1
powershell -NoProfile -Command "if((Get-FileHash images\vendor_boot.img).Hash -ne 'C48B548671F93837CF5ADB232079288B31F358663B0DDB10E26F5D7C69E3CE23'){exit 1}" || (echo images\vendor_boot.img is corrupt: delete it and run again & pause & exit /B 1)
fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *ruan" || echo Missmatching image and device
fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *ruan" || exit /B 1

::erase opcust and opconfig when cota enabled; Judge whether the partition exists before erase;
fastboot %* getvar partition-type:opcust 2>&1 | findstr /r /c:"^partition-type:opcust: raw"
if %errorlevel% equ 0 (
fastboot %* erase opcust || @echo "Erase opcust error" && exit /B 1
)
fastboot %* getvar partition-type:opconfig 2>&1 | findstr /r /c:"^partition-type:opconfig: raw"
if %errorlevel% equ 0 (
fastboot %* erase opconfig || @echo "Erase opconfig error" && exit /B 1
)

::check anti_version
if exist %~dp0images\anti_version.txt (for /f "delims==" %%a in (%~dp0images\anti_version.txt) do (set CURRENT_ANTI_VER=%%a))
if [%CURRENT_ANTI_VER%] EQU [] set CURRENT_ANTI_VER=0
for /f "tokens=2 delims=: " %%i in ('fastboot %* getvar anti 2^>^&1 ^| findstr /r /c:"anti:"') do (set version=%%i)
if [%version%] EQU [] set version=0
set anticheck="antirollback check pass"
if %version% GTR %CURRENT_ANTI_VER% set anticheck="Current device antirollback version is greater than this pakcage"
echo %anticheck% | findstr /r /c:"pass" || @echo "Antirollback check error" && exit /B 1


fastboot %* erase boot_a || @echo "Erase boot_a error" && exit /B 1
fastboot %* erase boot_b || @echo "Erase boot_b error" && exit /B 1
fastboot %* flash abl_a %~dp0images/abl.elf || @echo "Flash abl_a error" && exit 1
fastboot %* flash abl_b %~dp0images/abl.elf || @echo "Flash abl_b error" && exit 1
fastboot %* flash xbl_a %~dp0images/xbl_s.melf || @echo "Flash xbl_a error" && exit 1
fastboot %* flash xbl_b %~dp0images/xbl_s.melf || @echo "Flash xbl_b error" && exit 1
fastboot %* flash xbl_config_a %~dp0images/xbl_config.elf || @echo "Flash xbl_config_a error" && exit 1
fastboot %* flash xbl_config_b %~dp0images/xbl_config.elf || @echo "Flash xbl_config_b error" && exit 1
fastboot %* flash shrm_a %~dp0images/shrm.elf || @echo "Flash shrm_a error" && exit 1
fastboot %* flash shrm_b %~dp0images/shrm.elf || @echo "Flash shrm_b error" && exit 1
fastboot %* flash aop_a %~dp0images/aop.mbn || @echo "Flash aop_a error" && exit 1
fastboot %* flash aop_b %~dp0images/aop.mbn || @echo "Flash aop_b error" && exit 1
fastboot %* flash aop_config_a %~dp0images/aop_devcfg.mbn || @echo "Flash aop_config_a error" && exit 1
fastboot %* flash aop_config_b %~dp0images/aop_devcfg.mbn || @echo "Flash aop_config_b error" && exit 1
fastboot %* flash tz_a %~dp0images/tz.mbn || @echo "Flash tz_a error" && exit 1
fastboot %* flash tz_b %~dp0images/tz.mbn || @echo "Flash tz_b error" && exit 1
fastboot %* flash devcfg_a %~dp0images/devcfg.mbn || @echo "Flash devcfg_a error" && exit 1
fastboot %* flash devcfg_b %~dp0images/devcfg.mbn || @echo "Flash devcfg_b error" && exit 1
fastboot %* flash featenabler_a %~dp0images/featenabler.mbn || @echo "Flash featenabler_a error" && exit 1
fastboot %* flash featenabler_b %~dp0images/featenabler.mbn || @echo "Flash featenabler_b error" && exit 1
fastboot %* flash hyp_a %~dp0images/hypvmperformance.mbn || @echo "Flash hyp_a error" && exit 1
fastboot %* flash hyp_b %~dp0images/hypvmperformance.mbn || @echo "Flash hyp_b error" && exit 1
fastboot %* flash uefi_a %~dp0images/uefi.elf || @echo "Flash uefi error" && exit 1
fastboot %* flash uefi_b %~dp0images/uefi.elf || @echo "Flash uefi error" && exit 1
fastboot %* flash uefisecapp_a %~dp0images/uefi_sec.mbn || @echo "Flash uefisecapp error" && exit 1
fastboot %* flash uefisecapp_b %~dp0images/uefi_sec.mbn || @echo "Flash uefisecapp error" && exit 1
fastboot %* flash modem_a %~dp0images/NON-HLOS.bin || @echo "Flash modem error" && exit 1
fastboot %* flash modem_b %~dp0images/NON-HLOS.bin || @echo "Flash modem error" && exit 1

:: flash NON-HLOS.bin according to hwid
::for /f "tokens=3" %%i in ('fastboot oem hwid 2^>^&1 ^| findstr "HwCountry"') do set "result=%%i"
::if "%result%"=="GL" (
::  fastboot %* flash modem_ab %~dp0images\modem\global\NON-HLOS.bin || @echo "Flash modem error" && exit 1
::) else if "%result%"=="CN" (
::  fastboot %* flash modem_ab %~dp0images\modem\cn\NON-HLOS.bin || @echo "Flash modem error" && exit 1
::) else if "%result%"=="IN" (
::  fastboot %* flash modem_ab %~dp0images\modem\in\NON-HLOS.bin || @echo "Flash modem error" && exit 1
::) else (
::  @echo HwCountry error!
::  exit /b 1
::)

fastboot %* flash bluetooth_a %~dp0images/BTFM.bin || @echo "Flash bluetooth error" && exit 1
fastboot %* flash bluetooth_b %~dp0images/BTFM.bin || @echo "Flash bluetooth error" && exit 1
fastboot %* flash dsp_a %~dp0images/dspso.bin || @echo "Flash dsp error" && exit 1
fastboot %* flash dsp_b %~dp0images/dspso.bin || @echo "Flash dsp error" && exit 1
fastboot %* flash keymaster_a %~dp0images/keymint.mbn || @echo "Flash keymaster error" && exit 1
fastboot %* flash keymaster_b %~dp0images/keymint.mbn || @echo "Flash keymaster error" && exit 1
fastboot %* flash qupfw_a %~dp0images/qupv3fw.elf || @echo "Flash qupfw error" && exit 1
fastboot %* flash qupfw_b %~dp0images/qupv3fw.elf || @echo "Flash qupfw error" && exit 1
fastboot %* flash multiimgoem_a %~dp0images/multi_image.mbn || @echo "Flash multiimgoem error" && exit 1
fastboot %* flash multiimgoem_b %~dp0images/multi_image.mbn || @echo "Flash multiimgoem error" && exit 1
fastboot %* flash multiimgqti_a %~dp0images/multi_image_qti.mbn || @echo "Flash multiimgqti error" && exit 1
fastboot %* flash multiimgqti_b %~dp0images/multi_image_qti.mbn || @echo "Flash multiimgqti error" && exit 1
fastboot %* flash cpucp_a %~dp0images/cpucp.elf || @echo "Flash cpucp error" && exit 1
fastboot %* flash cpucp_b %~dp0images/cpucp.elf || @echo "Flash cpucp error" && exit 1
fastboot %* flash rtice %~dp0images\rtice.mbn || @echo "Flash rtice error" && exit /B 1
fastboot %* flash logfs %~dp0images/logfs_ufs_8mb.bin || @echo "Flash logfs error" && exit 1
fastboot %* flash rescue %~dp0images/rescue.img || @echo "Flash rescue error" && exit 1
fastboot %* flash storsec %~dp0images/storsec.mbn || @echo "Flash storsec error" && exit 1
fastboot %* flash toolsfv %~dp0images/tools.fv || @echo "Flash toolsfv error" && exit 1
fastboot %* flash qweslicstore_a %~dp0images/qweslicstore.bin || @echo "Flash qweslicstore error" && exit 1
fastboot %* flash qweslicstore_b %~dp0images/qweslicstore.bin || @echo "Flash qweslicstore error" && exit 1
fastboot %* flash xbl_ramdump_a %~dp0images/XblRamdump.elf || @echo "Flash xbl_ramdump error" && exit 1
fastboot %* flash xbl_ramdump_b %~dp0images/XblRamdump.elf || @echo "Flash xbl_ramdump error" && exit 1
fastboot %* flash xbl_sc_test_mode %~dp0images/xbl_sc_test_mode.bin || @echo "Flash xbl_sc_test_mode error" && exit 1
fastboot %* erase imagefv_a || @echo "Erase imagefv error" && exit /B 1
fastboot %* erase imagefv_b || @echo "Erase imagefv error" && exit /B 1
fastboot %* flash imagefv_a %~dp0images/imagefv.elf || @echo "Flash imagefv error" && exit 1
fastboot %* flash imagefv_b %~dp0images/imagefv.elf || @echo "Flash imagefv error" && exit 1
fastboot %* flash super %~dp0images/super.img || @echo "Flash super error" && exit 1
fastboot %* flash vendor_boot_a %~dp0images/vendor_boot.img || @echo "Flash vendor_boot error" && exit 1
fastboot %* flash vendor_boot_b %~dp0images/vendor_boot.img || @echo "Flash vendor_boot error" && exit 1
fastboot %* flash dtbo_a %~dp0images/dtbo.img || @echo "Flash dtbo error" && exit 1
fastboot %* flash dtbo_b %~dp0images/dtbo.img || @echo "Flash dtbo error" && exit 1
fastboot %* --disable-verity --disable-verification flash vbmeta_a %~dp0images/vbmeta.img || @echo "Flash vbmeta error" && exit 1
fastboot %* --disable-verity --disable-verification flash vbmeta_b %~dp0images/vbmeta.img || @echo "Flash vbmeta error" && exit 1
fastboot %* --disable-verity --disable-verification flash vbmeta_system_a %~dp0images/vbmeta_system.img || @echo "Flash vbmeta_system error" && exit 1
fastboot %* --disable-verity --disable-verification flash vbmeta_system_b %~dp0images/vbmeta_system.img || @echo "Flash vbmeta_system error" && exit 1
::fastboot %* flash cust %~dp0images/cust.img || @echo "Flash cust error" && exit 1
fastboot %* flash recovery_a %~dp0images/recovery.img || @echo "Flash recovery error" && exit 1
fastboot %* flash recovery_b %~dp0images/recovery.img || @echo "Flash recovery error" && exit 1
fastboot %* flash boot_a %~dp0images/boot.img || @echo "Flash boot error" && exit 1
fastboot %* flash boot_b %~dp0images/boot.img || @echo "Flash boot error" && exit 1
fastboot %* flash misc %~dp0images\misc.img || @echo "Flash misc error" && exit /B 1
fastboot %* set_active a || @echo "Set active a error" && exit 1
fastboot %* oem erase-vb-index
fastboot %* reboot || @echo "Reboot error" && exit 1
pause
