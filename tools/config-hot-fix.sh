#!/bin/sh -e

DIR=$PWD

cd ${DIR}/KERNEL/

#Nuke DSA SubSystem: 2020.02.20
./scripts/config --disable CONFIG_HAVE_NET_DSA
./scripts/config --disable CONFIG_NET_DSA

#SC16IS7XX breaks SERIAL_DEV_CTRL_TTYPORT, which breaks Bluetooth on wl18xx
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_CORE
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_I2C
./scripts/config --disable CONFIG_SERIAL_SC16IS7XX_SPI
./scripts/config --enable CONFIG_SERIAL_DEV_CTRL_TTYPORT

#WIMAX going to be removed soon...
./scripts/config --disable CONFIG_WIMAX
./scripts/config --disable CONFIG_WIMAX_I2400M
./scripts/config --disable CONFIG_WIMAX_I2400M_USB

#PHY: CONFIG_DP83867_PHY
./scripts/config --enable CONFIG_DP83867_PHY

#PRU: CONFIG_PRU_REMOTEPROC
./scripts/config --enable CONFIG_REMOTEPROC
./scripts/config --enable CONFIG_REMOTEPROC_CDEV
./scripts/config --enable CONFIG_WKUP_M3_RPROC
./scripts/config --module CONFIG_PRU_REMOTEPROC

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
./scripts/config --enable CONFIG_BPF_UNPRIV_DEFAULT_OFF
./scripts/config --enable CONFIG_CGROUP_MISC
./scripts/config --enable CONFIG_RESET_ATTACK_MITIGATION

#LIBCOMPOSITE built-in finally works... ;)
./scripts/config --enable CONFIG_USB_LIBCOMPOSITE
./scripts/config --enable CONFIG_USB_F_ACM
./scripts/config --enable CONFIG_USB_F_SS_LB
./scripts/config --enable CONFIG_USB_U_SERIAL
./scripts/config --enable CONFIG_USB_U_ETHER
./scripts/config --enable CONFIG_USB_U_AUDIO
./scripts/config --enable CONFIG_USB_F_SERIAL
./scripts/config --enable CONFIG_USB_F_OBEX
./scripts/config --enable CONFIG_USB_F_NCM
./scripts/config --enable CONFIG_USB_F_ECM
./scripts/config --module CONFIG_USB_F_PHONET
./scripts/config --enable CONFIG_USB_F_EEM
./scripts/config --enable CONFIG_USB_F_SUBSET
./scripts/config --enable CONFIG_USB_F_RNDIS
./scripts/config --enable CONFIG_USB_F_MASS_STORAGE
./scripts/config --enable CONFIG_USB_F_FS
./scripts/config --enable CONFIG_USB_F_UAC1
./scripts/config --enable CONFIG_USB_F_UAC2
./scripts/config --module CONFIG_USB_F_UVC
./scripts/config --enable CONFIG_USB_F_MIDI
./scripts/config --enable CONFIG_USB_F_HID
./scripts/config --enable CONFIG_USB_F_PRINTER
./scripts/config --module CONFIG_USB_F_TCM
./scripts/config --enable CONFIG_USB_CONFIGFS
./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

#2022.03.01 fix W1, needs to be a module now...
./scripts/config --enable CONFIG_W1
./scripts/config --module CONFIG_W1_MASTER_GPIO
./scripts/config --module CONFIG_W1_SLAVE_DS2430
./scripts/config --enable CONFIG_W1_SLAVE_DS2433_CRC

#2022.03.18 Re-Enable UIO PRUSS
./scripts/config --module CONFIG_UIO_PDRV_GENIRQ
./scripts/config --module CONFIG_UIO_PRUSS

#2022.12.25: still totally broken..
#[   26.460634] tps65217-charger tps65217-charger: DMA mask not set
#[   26.581296] genirq: Flags mismatch irq 53. 00002000 (tps65217-charger) vs. 00002000 (vbus)
#[   26.739119] tps65217-charger tps65217-charger: Unable to register irq 53 err -16
#[   26.842097] tps65217-charger: probe of tps65217-charger failed with error -16
./scripts/config --disable CONFIG_CHARGER_TPS65217

#2023.07.10
./scripts/config --disable CONFIG_GCC_PLUGINS

#2023.07.14
# MUSB DMA mode
./scripts/config --enable CONFIG_MUSB_PIO_ONLY
./scripts/config --disable CONFIG_USB_TI_CPPI41_DMA

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

#Rev D
./scripts/config --enable CONFIG_DRM_ITE_IT66121
./scripts/config --enable CONFIG_SYSFB_SIMPLEFB

#Cool for debugging, little noisy on production...
./scripts/config --disable CONFIG_UBSAN

#Debugging Defaults
./scripts/config --enable CONFIG_BPF_JIT_ALWAYS_ON
./scripts/config --enable CONFIG_BPF_PRELOAD
./scripts/config --enable CONFIG_BPF_PRELOAD_UMD
./scripts/config --enable CONFIG_IDLE_PAGE_TRACKING
./scripts/config --enable CONFIG_ANON_VMA_NAME
./scripts/config --enable CONFIG_USERFAULTFD
./scripts/config --enable CONFIG_LRU_GEN
./scripts/config --enable CONFIG_LRU_GEN_ENABLED
./scripts/config --enable CONFIG_HEADERS_INSTALL
./scripts/config --enable CONFIG_DEBUG_SECTION_MISMATCH
./scripts/config --enable CONFIG_PAGE_OWNER
./scripts/config --enable CONFIG_DEBUG_SHIRQ
./scripts/config --enable CONFIG_WQ_CPU_INTENSIVE_REPORT
./scripts/config --enable CONFIG_RCU_CPU_STALL_CPUTIME
./scripts/config --enable CONFIG_BOOTTIME_TRACING
./scripts/config --enable CONFIG_FUNCTION_PROFILER
./scripts/config --enable CONFIG_STACK_TRACER
./scripts/config --enable CONFIG_SCHED_TRACER
./scripts/config --enable CONFIG_HWLAT_TRACER
./scripts/config --enable CONFIG_TIMERLAT_TRACER
./scripts/config --enable CONFIG_FUNCTION_ERROR_INJECTION
./scripts/config --enable CONFIG_MEMTEST

./scripts/config --enable CONFIG_VIRT_CPU_ACCOUNTING_GEN
./scripts/config --enable CONFIG_PSI_DEFAULT_DISABLED
./scripts/config --enable CONFIG_PRINTK_INDEX
./scripts/config --enable CONFIG_MEMCG_V1
./scripts/config --enable CONFIG_CGROUP_DMEM

#This should have been AM33xx only...
./scripts/config --disable CONFIG_SMP
./scripts/config --disable CONFIG_SOC_OMAP5
./scripts/config --disable CONFIG_SOC_DRA7XX

cd ${DIR}/
