#!/bin/sh -e

DIR=$PWD

config_enable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xy" ] ; then
		echo "Setting: ${config}=y"
		./scripts/config --enable ${config}
	fi
}

config_disable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xn" ] ; then
		echo "Setting: ${config}=n"
		./scripts/config --disable ${config}
	fi
}

config_enable_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:# '$config' is not set:'$config'=y:g' .config
	fi
	if [ "x${test_module}" = "x${config}=m" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:'$config'=m:'$config'=y:g' .config
	fi
}

config_module_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=m"
		sed -i -e 's:# '$config' is not set:'$config'=m:g' .config
	else
		echo "$config=m" >> .config
	fi
}

config_module () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xm" ] ; then
		echo "Setting: ${config}=m"
		./scripts/config --module ${config}
	fi
}

config_string () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=\"${option}\""
		./scripts/config --set-str ${config} "${option}"
	fi
}

config_value () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-val ${config} ${option}
	fi
}

cd ${DIR}/KERNEL/

#Nuke DSA SubSystem: 2020.02.20
config="CONFIG_HAVE_NET_DSA" ; config_disable
config="CONFIG_NET_DSA" ; config_disable

#SC16IS7XX breaks SERIAL_DEV_CTRL_TTYPORT, which breaks Bluetooth on wl18xx
config="CONFIG_SERIAL_SC16IS7XX_CORE" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX_I2C" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX_SPI" ; config_disable
config="CONFIG_SERIAL_DEV_CTRL_TTYPORT" ; config_enable

#WIMAX going to be removed soon...
config="CONFIG_WIMAX" ; config_disable
config="CONFIG_WIMAX_I2400M" ; config_disable
config="CONFIG_WIMAX_I2400M_USB" ; config_disable

#PHY: CONFIG_DP83867_PHY
config="CONFIG_DP83867_PHY" ; config_enable

#PRU: CONFIG_PRU_REMOTEPROC
config="CONFIG_REMOTEPROC" ; config_enable
config="CONFIG_REMOTEPROC_CDEV" ; config_enable
config="CONFIG_WKUP_M3_RPROC" ; config_enable
config="CONFIG_PRU_REMOTEPROC" ; config_module

#Docker.io
./scripts/config --enable CONFIG_NETFILTER_XT_MATCH_IPVS
./scripts/config --enable CONFIG_CGROUP_BPF
./scripts/config --enable CONFIG_BLK_DEV_THROTTLING
./scripts/config --enable CONFIG_NET_CLS_CGROUP
./scripts/config --enable CONFIG_CGROUP_NET_PRIO
./scripts/config --enable CONFIG_IP_NF_TARGET_REDIRECT
./scripts/config --enable CONFIG_IP_VS
./scripts/config --enable CONFIG_IP_VS_NFCT
./scripts/config --enable CONFIG_IP_VS_PROTO_TCP
./scripts/config --enable CONFIG_IP_VS_PROTO_UDP
./scripts/config --enable CONFIG_IP_VS_RR
./scripts/config --enable CONFIG_SECURITY_SELINUX
./scripts/config --enable CONFIG_SECURITY_APPARMOR
./scripts/config --enable CONFIG_VXLAN
./scripts/config --enable CONFIG_IPVLAN
./scripts/config --enable CONFIG_DUMMY
./scripts/config --enable CONFIG_NF_NAT_FTP
./scripts/config --enable CONFIG_NF_CONNTRACK_FTP
./scripts/config --enable CONFIG_NF_NAT_TFTP
./scripts/config --enable CONFIG_NF_CONNTRACK_TFTP
./scripts/config --enable CONFIG_DM_THIN_PROVISIONING

#abi="5.13.0-trunk"
#kernel="5.13.9-1~exp2"
config="CONFIG_BPF_UNPRIV_DEFAULT_OFF" ; config_enable
config="CONFIG_CGROUP_MISC" ; config_enable
config="CONFIG_RESET_ATTACK_MITIGATION" ; config_enable

#LIBCOMPOSITE built-in finally works... ;)
config="CONFIG_USB_LIBCOMPOSITE" ; config_enable
config="CONFIG_USB_F_ACM" ; config_enable
config="CONFIG_USB_F_SS_LB" ; config_enable
config="CONFIG_USB_U_SERIAL" ; config_enable
config="CONFIG_USB_U_ETHER" ; config_enable
config="CONFIG_USB_U_AUDIO" ; config_enable
config="CONFIG_USB_F_SERIAL" ; config_enable
config="CONFIG_USB_F_OBEX" ; config_enable
config="CONFIG_USB_F_NCM" ; config_enable
config="CONFIG_USB_F_ECM" ; config_enable
config="CONFIG_USB_F_PHONET" ; config_module
config="CONFIG_USB_F_EEM" ; config_enable
config="CONFIG_USB_F_SUBSET" ; config_enable
config="CONFIG_USB_F_RNDIS" ; config_enable
config="CONFIG_USB_F_MASS_STORAGE" ; config_enable
config="CONFIG_USB_F_FS" ; config_enable
config="CONFIG_USB_F_UAC1" ; config_enable
config="CONFIG_USB_F_UAC2" ; config_enable
config="CONFIG_USB_F_UVC" ; config_module
config="CONFIG_USB_F_MIDI" ; config_enable
config="CONFIG_USB_F_HID" ; config_enable
config="CONFIG_USB_F_PRINTER" ; config_enable
config="CONFIG_USB_F_TCM" ; config_module
config="CONFIG_USB_CONFIGFS" ; config_enable
config="CONFIG_USB_CONFIGFS_SERIAL" ; config_enable
config="CONFIG_USB_CONFIGFS_ACM" ; config_enable
config="CONFIG_USB_CONFIGFS_OBEX" ; config_enable
config="CONFIG_USB_CONFIGFS_NCM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM_SUBSET" ; config_enable
config="CONFIG_USB_CONFIGFS_RNDIS" ; config_enable
config="CONFIG_USB_CONFIGFS_EEM" ; config_enable
config="CONFIG_USB_CONFIGFS_PHONET" ; config_enable
config="CONFIG_USB_CONFIGFS_MASS_STORAGE" ; config_enable
config="CONFIG_USB_CONFIGFS_F_LB_SS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_FS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC1" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC2" ; config_enable
config="CONFIG_USB_CONFIGFS_F_MIDI" ; config_enable
config="CONFIG_USB_CONFIGFS_F_HID" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UVC" ; config_enable
config="CONFIG_USB_CONFIGFS_F_PRINTER" ; config_enable

#2022.03.01 fix W1, needs to be a module now...
config="CONFIG_W1" ; config_enable
config="CONFIG_W1_MASTER_GPIO" ; config_module
config="CONFIG_W1_SLAVE_DS2430" ; config_module
config="CONFIG_W1_SLAVE_DS2433_CRC" ; config_enable

#2022.03.18 Re-Enable UIO PRUSS
config="CONFIG_UIO_PDRV_GENIRQ" ; config_module
config="CONFIG_UIO_PRUSS" ; config_module

#2022.12.25: still totally broken..
#[   26.460634] tps65217-charger tps65217-charger: DMA mask not set
#[   26.581296] genirq: Flags mismatch irq 53. 00002000 (tps65217-charger) vs. 00002000 (vbus)
#[   26.739119] tps65217-charger tps65217-charger: Unable to register irq 53 err -16
#[   26.842097] tps65217-charger: probe of tps65217-charger failed with error -16
config="CONFIG_CHARGER_TPS65217" ; config_disable

#2023.07.10
config="CONFIG_GCC_PLUGINS" ; config_disable

#2023.07.14
# MUSB DMA mode
config="CONFIG_MUSB_PIO_ONLY" ; config_enable
config="CONFIG_USB_TI_CPPI41_DMA" ; config_disable

# We recommend to turn off Real-Time group scheduling in the
# kernel when using systemd. RT group scheduling effectively
# makes RT scheduling unavailable for most userspace, since it
# requires explicit assignment of RT budgets to each unit whose
# processes making use of RT. As there's no sensible way to
# assign these budgets automatically this cannot really be
# fixed, and it's best to disable group scheduling hence.
./scripts/config --disable CONFIG_RT_GROUP_SCHED

#iwd
./scripts/config --enable CONFIG_CRYPTO_USER_API_SKCIPHER
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_HMAC
./scripts/config --enable CONFIG_CRYPTO_CMAC
./scripts/config --enable CONFIG_CRYPTO_MD4
./scripts/config --enable CONFIG_CRYPTO_MD5
./scripts/config --enable CONFIG_CRYPTO_SHA256
./scripts/config --enable CONFIG_CRYPTO_SHA512
./scripts/config --enable CONFIG_CRYPTO_AES
./scripts/config --enable CONFIG_CRYPTO_ECB
./scripts/config --enable CONFIG_CRYPTO_DES
./scripts/config --enable CONFIG_CRYPTO_CBC
./scripts/config --enable CONFIG_KEY_DH_OPERATIONS

#WiFi, removed in 6.7-rc1
./scripts/config --disable CONFIG_WLAN_VENDOR_CISCO
./scripts/config --disable CONFIG_HOSTAP
./scripts/config --disable CONFIG_HERMES
./scripts/config --disable CONFIG_USB_ZD1201
./scripts/config --disable CONFIG_RTL8192U

#removed in 6.7-rc1
./scripts/config --disable CONFIG_DEV_APPLETALK

#TI delta 09.01.00.004:
./scripts/config --enable CONFIG_APERTURE_HELPERS
./scripts/config --enable CONFIG_FB_CFB_FILLRECT
./scripts/config --enable CONFIG_FB_CFB_COPYAREA
./scripts/config --enable CONFIG_FB_CFB_IMAGEBLIT
./scripts/config --enable CONFIG_FB_SIMPLE
./scripts/config --module CONFIG_TI_EQEP

./scripts/config --module CONFIG_VIDEO_TI_VIP
./scripts/config --module CONFIG_VIDEO_OV1063X
./scripts/config --module CONFIG_VIDEO_OV2312
./scripts/config --module CONFIG_VIDEO_OV5640
./scripts/config --module CONFIG_VIDEO_OV5645
./scripts/config --module CONFIG_VIDEO_IMX219
./scripts/config --module CONFIG_VIDEO_IMX390
./scripts/config --module CONFIG_VIDEO_OX05B1S

#enable SPI/W1
./scripts/config --enable CONFIG_SPI_OMAP24XX
./scripts/config --enable CONFIG_W1
./scripts/config --enable CONFIG_MIKROBUS

#20240305: regression on discord, some systemd can no longer load *.xz modules...
./scripts/config --disable CONFIG_MODULE_DECOMPRESS

#enable CONFIG_DYNAMIC_FTRACE
./scripts/config --enable CONFIG_FUNCTION_TRACER
./scripts/config --enable CONFIG_DYNAMIC_FTRACE

./scripts/config --enable CONFIG_MODULE_COMPRESS
./scripts/config --disable CONFIG_MODULE_COMPRESS_GZIP
./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
./scripts/config --disable CONFIG_MODULE_COMPRESS_ZSTD
./scripts/config --enable CONFIG_MODULE_COMPRESS_ALL
./scripts/config --enable CONFIG_GPIO_AGGREGATOR
./scripts/config --module CONFIG_PWM_GPIO

#10.00.05
#REMOTEPROC
./scripts/config --module CONFIG_RPMSG
./scripts/config --module CONFIG_RPMSG_NS
./scripts/config --module CONFIG_RPMSG_PRU
./scripts/config --enable CONFIG_RPMSG_VIRTIO

#TI: 10.01.01
./scripts/config --module CONFIG_OMAP2PLUS_MBOX

#new in v6.12.x
./scripts/config --enable CONFIG_RPMB
./scripts/config --module CONFIG_ADXL380_SPI
./scripts/config --module CONFIG_ADXL380_I2C
./scripts/config --module CONFIG_AD4000
./scripts/config --module CONFIG_AD4695
./scripts/config --module CONFIG_PAC1921
./scripts/config --module CONFIG_LTC2664
./scripts/config --module CONFIG_ENS210
./scripts/config --module CONFIG_BH1745
./scripts/config --module CONFIG_SDP500
./scripts/config --module CONFIG_HX9023S
./scripts/config --module CONFIG_AW96103

#debian 6.12~rc6-1~exp1
./scripts/config --enable CONFIG_ZONE_DEVICE
./scripts/config --module CONFIG_IP_VS_TWOS
./scripts/config --module CONFIG_VIDEO_OV5648
./scripts/config --enable CONFIG_DRM_DISPLAY_DP_AUX_CHARDEV
./scripts/config --module CONFIG_TI_PRUSS

#debian 6.12.6-1
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZ4HC
./scripts/config --enable CONFIG_ZRAM_BACKEND_ZSTD
./scripts/config --enable CONFIG_ZRAM_BACKEND_DEFLATE
./scripts/config --enable CONFIG_ZRAM_DEF_COMP_LZ4
./scripts/config --set-str CONFIG_ZRAM_DEF_COMP "lz4"

#debian 6.12.16-1
./scripts/config --enable CONFIG_RCU_LAZY
./scripts/config --module CONFIG_NSM
./scripts/config --module CONFIG_NITRO_ENCLAVES
./scripts/config --module CONFIG_USB_MASS_STORAGE

#debian 6.12.20-1
./scripts/config --module CONFIG_VIDEO_OV5675
./scripts/config --enable CONFIG_RPCSEC_GSS_KRB5_ENCTYPES_AES_SHA2

#debian 6.13.5-1
./scripts/config --enable CONFIG_UDMABUF

#debian 6.13.7-1
./scripts/config --module CONFIG_VIRTIO_IOMMU
./scripts/config --enable CONFIG_CRYPTO_ECDSA

#debian 6.13.8-1
./scripts/config --enable CONFIG_NVME_TARGET_PASSTHRU
./scripts/config --module CONFIG_NVME_TARGET_LOOP
./scripts/config --module CONFIG_NVME_TARGET_FCLOOP

#debian 6.13.11-1
./scripts/config --enable CONFIG_KALLSYMS_ALL

#debian 6.14.3-1~exp1
./scripts/config --enable CONFIG_UBSAN
./scripts/config --enable CONFIG_UBSAN_BOUNDS
./scripts/config --enable CONFIG_UBSAN_BOUNDS_STRICT
./scripts/config --enable CONFIG_UBSAN_SHIFT
./scripts/config --disable CONFIG_UBSAN_BOOL
./scripts/config --disable CONFIG_UBSAN_ENUM
./scripts/config --enable CONFIG_FPROBE

#new in v6.14
./scripts/config --module CONFIG_NTSYNC
./scripts/config --module CONFIG_PPS_GENERATOR
./scripts/config --module CONFIG_SENSORS_CRPS
./scripts/config --module CONFIG_SENSORS_TPS25990
./scripts/config --module CONFIG_BD79703
./scripts/config --module CONFIG_OPT4060
./scripts/config --enable CONFIG_FPROBE

#TI: 11.00.01
./scripts/config --enable CONFIG_SRAM_DMA_HEAP
./scripts/config --module CONFIG_CC33XX
./scripts/config --module CONFIG_CC33XX_SDIO
./scripts/config --module CONFIG_VIDEO_IMX390
./scripts/config --enable CONFIG_DMABUF_HEAPS
./scripts/config --enable CONFIG_DMABUF_HEAPS_SYSTEM
./scripts/config --enable CONFIG_DMABUF_HEAPS_CMA
./scripts/config --enable CONFIG_DMABUF_HEAPS_CARVEOUT

#TI: 11.00.02
./scripts/config --module CONFIG_REGULATOR_RASPBERRYPI_TOUCHSCREEN_ATTINY
./scripts/config --module CONFIG_DRM_TOSHIBA_TC358762
#./scripts/config --module CONFIG_DRM_CDNS_DSI
#./scripts/config --module CONFIG_DRM_CDNS_DSI_J721E
#./scripts/config --module CONFIG_HWSPINLOCK_OMAP
#./scripts/config --module CONFIG_PWM_OMAP_DMTIMER
#./scripts/config --module CONFIG_PHY_CADENCE_DPHY
./scripts/config --module CONFIG_TI_ECAP_CAPTURE

#TI: 11.00.04
./scripts/config --enable CONFIG_MTD_SPI_NAND
./scripts/config --enable CONFIG_MTD_UBI
./scripts/config --enable CONFIG_TI_K3_UDMA_AM62L
./scripts/config --enable CONFIG_UBIFS_FS
./scripts/config --enable CONFIG_CRYPTO_ZSTD
./scripts/config --enable CONFIG_ZSTD_COMPRESS

#TI: 11.00.06
./scripts/config --module CONFIG_CRYPTO_CRC64_ISO3309
./scripts/config --enable CONFIG_CRYPTO_USER_API_HASH
./scripts/config --enable CONFIG_CRYPTO_DEV_TI_MCRC64
./scripts/config --enable CONFIG_CRYPTO_DEV_TI_DTHEV2
./scripts/config --module CONFIG_TOUCHSCREEN_ILI210X

#TI: 11.00.07
./scripts/config --module CONFIG_SERIAL_8250_PRUSS
./scripts/config --module CONFIG_VIDEO_IMX728
./scripts/config --module CONFIG_VIDEO_OV2312

#TI: 11.00.08
./scripts/config --module CONFIG_VIDEO_OX05B1S

#new in v6.15
./scripts/config --module CONFIG_FWCTL
./scripts/config --module CONFIG_IWLMLD
./scripts/config --module CONFIG_RTW88_8814AU
./scripts/config --module CONFIG_SPI_OFFLOAD_TRIGGER_PWM
./scripts/config --module CONFIG_SENSORS_HTU31
./scripts/config --module CONFIG_SENSORS_INA233
./scripts/config --module CONFIG_HID_UNIVERSAL_PIDFF
./scripts/config --module CONFIG_AD4030
./scripts/config --module CONFIG_AD4851
./scripts/config --module CONFIG_AD7191
./scripts/config --module CONFIG_TI_ADS7138
./scripts/config --module CONFIG_ADIS16550
./scripts/config --module CONFIG_AL3000A
./scripts/config --module CONFIG_APDS9160
./scripts/config --module CONFIG_SI7210

#debian Trixie has fubared lz4/lz4c, back to xz for stabilty...
#  LZ4     arch/arm/boot/compressed/piggy_data
#Error : stdout won't be used ! Do you want multiple input files (-m) ?
#make[3]: *** [arch/arm/boot/compressed/Makefile:156: arch/arm/boot/compressed/piggy_data] Error 1

./scripts/config --disable CONFIG_KERNEL_LZO
./scripts/config --disable CONFIG_KERNEL_LZ4
./scripts/config --enable CONFIG_KERNEL_XZ

#configure CONFIG_EXTRA_FIRMWARE
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin"
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_XZ
./scripts/config --enable CONFIG_FW_LOADER_COMPRESS_ZSTD

#BeagleBoard.org
./scripts/config --enable CONFIG_MSPM0_I2C
./scripts/config --module CONFIG_SEG_LED_GPIO
./scripts/config --module CONFIG_INPUT_PWM_BEEPER
./scripts/config --module CONFIG_SND_SOC_TLV320AIC3X_I2C
./scripts/config --module CONFIG_WIZNET_W5100
./scripts/config --module CONFIG_WIZNET_W5100_SPI

#Regressions:
./scripts/config --enable CONFIG_MMC_BLOCK

cd ${DIR}/
