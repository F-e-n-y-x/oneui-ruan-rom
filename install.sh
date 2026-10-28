#!/bin/bash
# One UI 8.5 for Redmi Pad Pro 5G (ruan) v1.6-b30-20261028: first install, WIPES ALL DATA
read -p "This erases everything on the tablet. Type YES to continue: " a
[ "$a" = YES ] || exit 1
cd "$(dirname "$0")"
# Join the split images (git stores files up to 100 MB), once, then verify them.
for f in NON-HLOS.bin boot.img recovery.img super.img userdata.img vendor_boot.img; do
    [ -f "images/$f" ] || cat "images/$f".part* > "images/$f" || exit 1
done
if command -v sha256sum >/dev/null; then SUM="sha256sum -c"; else SUM="shasum -a 256 -c"; fi
(cd images && $SUM ../images.sha256) || { echo "A joined image is corrupt: delete it and run again (or re-download)."; exit 1; }
fastboot $* getvar product 2>&1 | grep "^product: *ruan"
if [ $? -ne 0  ] ; then echo "Missmatching image and device"; exit 1; fi

# erase opcust and opconfig when cota enabled; Judge whether the partition exists before erase;
fastboot $* getvar partition-type:opcust 2>&1 | grep "^partition-type:opcust: raw"
if [ $? -eq 0 ]; then
    fastboot $* erase opcust
    if [ $? -ne 0 ] ; then echo "Erase opcust error"; exit 1; fi
else
    echo "No partition opcust found, skip erase opcust"
fi
fastboot $* getvar partition-type:opconfig 2>&1 | grep "^partition-type:opconfig: raw"
if [ $? -eq 0 ]; then
    fastboot $* erase opconfig
    if [ $? -ne 0 ] ; then echo "Erase opconfig error"; exit 1; fi
else
    echo "No partition opconfig found, skip erase opconfig"
fi

#check anti_version
if [ -e $(dirname $0)/images/anti_version.txt ]; then
CURRENT_ANTI_VER=`cat $(dirname $0)/images/anti_version.txt`
fi
if [ -z "$CURRENT_ANTI_VER" ]; then CURRENT_ANTI_VER=0; fi
ver=`fastboot $* getvar anti 2>&1 | grep -oP "anti: \K[0-9]+"`
if [ -z "$ver" ]; then ver=0; fi
if [ $ver -gt $CURRENT_ANTI_VER ]; then echo "Current device antirollback version is greater than this pakcage"; exit 1; fi


fastboot $* erase boot_a
fastboot $* erase boot_b
if [ $? -ne 0 ] ; then echo "Erase boot error"; exit 1; fi
fastboot $* flash abl_a `dirname $0`/images/abl.elf
fastboot $* flash abl_b `dirname $0`/images/abl.elf
if [ $? -ne 0 ] ; then echo "Flash abl error"; exit 1; fi
fastboot $* flash xbl_a `dirname $0`/images/xbl_s.melf
fastboot $* flash xbl_b `dirname $0`/images/xbl_s.melf
if [ $? -ne 0 ] ; then echo "Flash xbl error"; exit 1; fi
fastboot $* flash xbl_config_a `dirname $0`/images/xbl_config.elf
fastboot $* flash xbl_config_b `dirname $0`/images/xbl_config.elf
if [ $? -ne 0 ] ; then echo "Flash xbl_config error"; exit 1; fi
fastboot $* flash shrm_a `dirname $0`/images/shrm.elf
fastboot $* flash shrm_b `dirname $0`/images/shrm.elf
if [ $? -ne 0 ] ; then echo "Flash shrm error"; exit 1; fi
fastboot $* flash aop_a `dirname $0`/images/aop.mbn
fastboot $* flash aop_b `dirname $0`/images/aop.mbn
if [ $? -ne 0 ] ; then echo "Flash aop error"; exit 1; fi
fastboot $* flash aop_config_a `dirname $0`/images/aop_devcfg.mbn
fastboot $* flash aop_config_b `dirname $0`/images/aop_devcfg.mbn
if [ $? -ne 0 ] ; then echo "Flash aop_config error"; exit 1; fi
fastboot $* flash tz_a `dirname $0`/images/tz.mbn
fastboot $* flash tz_b `dirname $0`/images/tz.mbn
if [ $? -ne 0 ] ; then echo "Flash tz error"; exit 1; fi
fastboot $* flash devcfg_a `dirname $0`/images/devcfg.mbn
fastboot $* flash devcfg_b `dirname $0`/images/devcfg.mbn
if [ $? -ne 0 ] ; then echo "Flash devcfg error"; exit 1; fi
fastboot $* flash featenabler_a `dirname $0`/images/featenabler.mbn
fastboot $* flash featenabler_b `dirname $0`/images/featenabler.mbn
if [ $? -ne 0 ] ; then echo "Flash featenabler error"; exit 1; fi
fastboot $* flash hyp_a `dirname $0`/images/hypvmperformance.mbn
fastboot $* flash hyp_b `dirname $0`/images/hypvmperformance.mbn
if [ $? -ne 0 ] ; then echo "Flash hyp error"; exit 1; fi
fastboot $* flash uefi_a `dirname $0`/images/uefi.elf
fastboot $* flash uefi_b `dirname $0`/images/uefi.elf
if [ $? -ne 0 ] ; then echo "Flash uefi error"; exit 1; fi
fastboot $* flash uefisecapp_a `dirname $0`/images/uefi_sec.mbn
fastboot $* flash uefisecapp_b `dirname $0`/images/uefi_sec.mbn
if [ $? -ne 0 ] ; then echo "Flash uefisecapp error"; exit 1; fi

fastboot $* flash modem_a `dirname $0`/images/NON-HLOS.bin;
fastboot $* flash modem_b `dirname $0`/images/NON-HLOS.bin;
if [ $? -ne 0 ] ; then echo "Flash modem error"; exit 1; fi

#fastboot $* flash modem_ab `dirname $0`/images/NON-HLOS.bin
#fastboot oem hwid  2>&1 |grep "HwCountry" |awk '{print $3}' | \
#    {
#        read result;
#        if [ "${result}" == "GL" ]; then
#            fastboot $* flash modem_ab `dirname $0`/images/modem/global/NON-HLOS.bin;
#            if [ $? -ne 0 ] ; then echo "Flash modem error"; exit 1; fi
 #       elif [ "${result}" == "CN" ]; then
#            fastboot $* flash modem_ab `dirname $0`/images/modem/cn/NON-HLOS.bin;
#            if [ $? -ne 0 ] ; then echo "Flash modem error"; exit 1; fi
#        elif [ "${result}" == "IN" ]; then
#            fastboot $* flash modem_ab `dirname $0`/images/modem/in/NON-HLOS.bin;
#            if [ $? -ne 0 ] ; then echo "Flash modem error"; exit 1; fi
 #       else
#            echo "HwCountry error!";
#            exit 1
#        fi;
#    }

fastboot $* flash bluetooth_a `dirname $0`/images/BTFM.bin
fastboot $* flash bluetooth_b `dirname $0`/images/BTFM.bin
if [ $? -ne 0 ] ; then echo "Flash bluetooth error"; exit 1; fi
fastboot $* flash dsp_a `dirname $0`/images/dspso.bin
fastboot $* flash dsp_b `dirname $0`/images/dspso.bin
if [ $? -ne 0 ] ; then echo "Flash dsp error"; exit 1; fi
fastboot $* flash keymaster_a `dirname $0`/images/keymint.mbn
fastboot $* flash keymaster_b `dirname $0`/images/keymint.mbn
if [ $? -ne 0 ] ; then echo "Flash keymaster error"; exit 1; fi
fastboot $* flash qupfw_a `dirname $0`/images/qupv3fw.elf
fastboot $* flash qupfw_b `dirname $0`/images/qupv3fw.elf
if [ $? -ne 0 ] ; then echo "Flash qupfw error"; exit 1; fi
fastboot $* flash multiimgoem_a `dirname $0`/images/multi_image.mbn
fastboot $* flash multiimgoem_b `dirname $0`/images/multi_image.mbn
if [ $? -ne 0 ] ; then echo "Flash multiimgoem error"; exit 1; fi
fastboot $* flash multiimgqti_a `dirname $0`/images/multi_image_qti.mbn
fastboot $* flash multiimgqti_b `dirname $0`/images/multi_image_qti.mbn
if [ $? -ne 0 ] ; then echo "Flash multiimgqti error"; exit 1; fi
fastboot $* flash cpucp_a `dirname $0`/images/cpucp.elf
fastboot $* flash cpucp_b `dirname $0`/images/cpucp.elf
if [ $? -ne 0 ] ; then echo "Flash cpucp error"; exit 1; fi
fastboot $* flash rtice `dirname $0`/images/rtice.mbn
if [ $? -ne 0 ] ; then echo "Flash rtice error"; exit 1; fi
fastboot $* flash logfs `dirname $0`/images/logfs_ufs_8mb.bin
if [ $? -ne 0 ] ; then echo "Flash logfs error"; exit 1; fi
fastboot $* flash rescue `dirname $0`/images/rescue.img
if [ $? -ne 0 ] ; then echo "Flash rescue error"; exit 1; fi
fastboot $* flash storsec `dirname $0`/images/storsec.mbn
if [ $? -ne 0 ] ; then echo "Flash storsec error"; exit 1; fi
fastboot $* flash toolsfv `dirname $0`/images/tools.fv
if [ $? -ne 0 ] ; then echo "Flash toolsfv error"; exit 1; fi
fastboot $* flash qweslicstore_a `dirname $0`/images/qweslicstore.bin
fastboot $* flash qweslicstore_b `dirname $0`/images/qweslicstore.bin
if [ $? -ne 0 ] ; then echo "Flash qweslicstore error"; exit 1; fi
fastboot $* flash xbl_ramdump_a `dirname $0`/images/XblRamdump.elf
fastboot $* flash xbl_ramdump_b `dirname $0`/images/XblRamdump.elf
if [ $? -ne 0 ] ; then echo "Flash xbl_ramdump error"; exit 1; fi
fastboot $* flash xbl_sc_test_mode `dirname $0`/images/xbl_sc_test_mode.bin
if [ $? -ne 0 ] ; then echo "Flash xbl_sc_test_mode error"; exit 1; fi
fastboot $* erase imagefv_a
fastboot $* erase imagefv_b
if [ $? -ne 0 ] ; then echo "Erase imagesfv error"; exit 1; fi
fastboot $* flash imagefv_a `dirname $0`/images/imagefv.elf
fastboot $* flash imagefv_b `dirname $0`/images/imagefv.elf
if [ $? -ne 0 ] ; then echo "Flash toolsfv error"; exit 1; fi
fastboot $* flash super `dirname $0`/images/super.img
if [ $? -ne 0 ] ; then echo "Flash super error"; exit 1; fi
fastboot $* flash vendor_boot_a `dirname $0`/images/vendor_boot.img
fastboot $* flash vendor_boot_b `dirname $0`/images/vendor_boot.img
if [ $? -ne 0 ] ; then echo "Flash vendor_boot error"; exit 1; fi
fastboot $* flash dtbo_a `dirname $0`/images/dtbo.img
fastboot $* flash dtbo_b `dirname $0`/images/dtbo.img
if [ $? -ne 0 ] ; then echo "Flash dtbo error"; exit 1; fi
fastboot $* --disable-verity --disable-verification flash vbmeta_a `dirname $0`/images/vbmeta.img
fastboot $* --disable-verity --disable-verification flash vbmeta_b `dirname $0`/images/vbmeta.img
if [ $? -ne 0 ] ; then echo "Flash vbmeta error"; exit 1; fi
fastboot $* --disable-verity --disable-verification flash vbmeta_system_a `dirname $0`/images/vbmeta_system.img
fastboot $* --disable-verity --disable-verification flash vbmeta_system_b `dirname $0`/images/vbmeta_system.img
if [ $? -ne 0 ] ; then echo "Flash vbmeta_system error"; exit 1; fi
fastboot $* erase metadata
if [ $? -ne 0 ] ; then echo "Erase metadata error"; exit 1; fi
fastboot $* flash metadata `dirname $0`/images/metadata.img
if [ $? -ne 0 ] ; then echo "Flash metadata error"; exit 1; fi
fastboot $* flash userdata `dirname $0`/images/userdata.img
if [ $? -ne 0 ] ; then echo "Flash userdata error"; exit 1; fi
#fastboot $* flash cust `dirname $0`/images/cust.img
#if [ $? -ne 0 ] ; then echo "Flash cust error"; exit 1; fi
fastboot $* flash recovery_a `dirname $0`/images/recovery.img
fastboot $* flash recovery_b `dirname $0`/images/recovery.img
if [ $? -ne 0 ] ; then echo "Flash recovery error"; exit 1; fi
fastboot $* flash boot_a `dirname $0`/images/boot.img
fastboot $* flash boot_b `dirname $0`/images/boot.img
if [ $? -ne 0 ] ; then echo "Flash boot error"; exit 1; fi
fastboot $* flash misc `dirname $0`/images/misc.img
if [ $? -ne 0 ] ; then echo "Flash misc error"; exit 1; fi
fastboot $* set_active a
if [ $? -ne 0 ] ; then echo "set_active a error"; exit 1; fi
fastboot $* oem erase-vb-index
fastboot $* reboot
if [ $? -ne 0 ] ; then echo "Reboot error"; exit 1; fi
