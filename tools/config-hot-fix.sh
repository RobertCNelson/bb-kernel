#!/bin/sh -e

DIR=$PWD

cd ${DIR}/KERNEL/

#
# Timers subsystem
#
./scripts/config --enable CONFIG_NO_HZ_IDLE
./scripts/config --enable CONFIG_CONTEXT_TRACKING_USER_FORCE

#
# BPF subsystem
#
./scripts/config --enable CONFIG_BPF_PRELOAD
./scripts/config --enable CONFIG_BPF_JIT_ALWAYS_ON
./scripts/config --enable CONFIG_BPF_PRELOAD_UMD

# end of BPF subsystem
./scripts/config --enable CONFIG_PREEMPT

#
# CPU/Task time and stats accounting
#
./scripts/config --enable CONFIG_PSI_DEFAULT_DISABLED

# end of RCU Subsystem
./scripts/config --enable CONFIG_IKCONFIG
./scripts/config --enable CONFIG_IKCONFIG_PROC
./scripts/config --module CONFIG_IKHEADERS
./scripts/config --enable CONFIG_PRINTK_INDEX

# end of Scheduler features
./scripts/config --enable CONFIG_MEMCG_V1
./scripts/config --enable CONFIG_CGROUP_DMEM
./scripts/config --enable CONFIG_KALLSYMS_ALL

#
# Kexec and crash features
#
./scripts/config --disable CONFIG_KEXEC

#
# CPU Core family selection
#
./scripts/config --disable CONFIG_ARCH_VIRT
./scripts/config --disable CONFIG_ARCH_ASPEED
./scripts/config --disable CONFIG_ARCH_BCM
./scripts/config --disable CONFIG_ARCH_EXYNOS
./scripts/config --disable CONFIG_ARCH_HIGHBANK
./scripts/config --disable CONFIG_ARCH_MXC
./scripts/config --disable CONFIG_ARCH_MESON
./scripts/config --disable CONFIG_ARCH_MMP
./scripts/config --disable CONFIG_ARCH_MVEBU

# AM33XX only!
./scripts/config --disable CONFIG_ARCH_OMAP3
./scripts/config --disable CONFIG_ARCH_OMAP4
./scripts/config --disable CONFIG_SOC_OMAP5
./scripts/config --disable CONFIG_SOC_DRA7XX

./scripts/config --disable CONFIG_ARCH_ROCKCHIP
./scripts/config --disable CONFIG_ARCH_INTEL_SOCFPGA
./scripts/config --disable CONFIG_ARCH_STM32
./scripts/config --disable CONFIG_ARCH_SUNXI
./scripts/config --disable CONFIG_ARCH_TEGRA
./scripts/config --disable CONFIG_ARCH_VEXPRESS
./scripts/config --disable CONFIG_ARCH_WM8850

#
# Processor Features
#
./scripts/config --disable CONFIG_CACHE_L2X0
#Cortex-A9 720789, 754322, 775420
./scripts/config --disable CONFIG_ARM_ERRATA_720789
./scripts/config --disable CONFIG_ARM_ERRATA_754322
./scripts/config --disable CONFIG_ARM_ERRATA_775420

#
# Kernel Features
#
./scripts/config --disable CONFIG_SMP
./scripts/config --enable CONFIG_THUMB2_KERNEL
./scripts/config --disable CONFIG_XEN

#
# Power management options
#
./scripts/config --enable CONFIG_PM_AUTOSLEEP
./scripts/config --enable CONFIG_PM_WAKELOCKS

#
# CPU Frequency scaling
#
./scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE

#
# CPU frequency scaling drivers
#
./scripts/config --enable CONFIG_CPUFREQ_DT
./scripts/config --disable CONFIG_ARM_OMAP2PLUS_CPUFREQ

#
# CPU Idle
#
./scripts/config --enable CONFIG_CPU_IDLE
./scripts/config --enable CONFIG_CPU_IDLE_GOV_LADDER
./scripts/config --enable CONFIG_CPU_IDLE_GOV_MENU

#
# ARM CPU Idle Drivers
#
./scripts/config --enable CONFIG_ARM_CPUIDLE
./scripts/config --enable CONFIG_ARM_PSCI_CPUIDLE

# end of General architecture-dependent options
./scripts/config --disable CONFIG_MODULE_SIG
./scripts/config --disable CONFIG_MODULE_DECOMPRESS
./scripts/config --enable CONFIG_BLK_CGROUP_IOPRIO

# end of Slab allocator options
./scripts/config --enable CONFIG_IDLE_PAGE_TRACKING
./scripts/config --enable CONFIG_ANON_VMA_NAME

#
# Networking options
#
./scripts/config --enable CONFIG_IP_PNP
./scripts/config --enable CONFIG_IP_PNP_DHCP
./scripts/config --enable CONFIG_IP_PNP_BOOTP
./scripts/config --enable CONFIG_IP_PNP_RARP
./scripts/config --enable CONFIG_NET_IP_TUNNEL
./scripts/config --enable CONFIG_NET_UDP_TUNNEL

#
# Core Netfilter Configuration
#
./scripts/config --enable CONFIG_NETFILTER_XTABLES

#
# IP: Netfilter Configuration
#
./scripts/config --enable CONFIG_IP_NF_IPTABLES

./scripts/config --disable CONFIG_NET_DSA

#
# Classification
#
./scripts/config --enable CONFIG_NET_CLS_CGROUP
./scripts/config --enable CONFIG_DNS_RESOLVER

#
# Bluetooth device drivers
#
./scripts/config --disable CONFIG_BT_HCIBTUSB_AUTOSUSPEND

# end of Bluetooth device drivers
./scripts/config --disable CONFIG_CFG80211_DEFAULT_PS
./scripts/config --enable CONFIG_RFKILL
./scripts/config --enable CONFIG_RFKILL_GPIO

#
# Device Drivers
#
./scripts/config --disable CONFIG_PCI

#
# Generic Driver Options
#
./scripts/config --enable CONFIG_DEVTMPFS_MOUNT

#
# Firmware loader
#
./scripts/config --enable CONFIG_FW_LOADER_SYSFS
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE "regulatory.db regulatory.db.p7s am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin"
./scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR "firmware"
./scripts/config --enable CONFIG_FW_LOADER_USER_HELPER
./scripts/config --disable CONFIG_FW_LOADER_USER_HELPER_FALLBACK
./scripts/config --enable CONFIG_FW_UPLOAD

#
# Bus devices
#
./scripts/config --disable CONFIG_OMAP_OCP2SCP
./scripts/config --disable CONFIG_VEXPRESS_CONFIG
./scripts/config --disable CONFIG_MHI_BUS

# end of ARM System Control and Management Interface Protocol
./scripts/config --enable CONFIG_SYSFB_SIMPLEFB
./scripts/config --disable CONFIG_FW_CS_DSP
./scripts/config --disable CONFIG_GOOGLE_FIRMWARE

# end of Firmware Drivers
./scripts/config --module CONFIG_FWCTL

# end of LPDDR & LPDDR2 PCM memory drivers
./scripts/config --enable CONFIG_OF_OVERLAY
./scripts/config --disable CONFIG_PARPORT
./scripts/config --enable CONFIG_ZRAM_BACKEND_LZO

#
# NVME Support
#
./scripts/config --disable CONFIG_NVME_KEYRING
./scripts/config --disable CONFIG_NVME_CORE
./scripts/config --disable CONFIG_NVME_MULTIPATH
./scripts/config --disable CONFIG_NVME_HWMON
./scripts/config --disable CONFIG_NVME_FABRICS
./scripts/config --disable CONFIG_NVME_RDMA
./scripts/config --disable CONFIG_NVME_FC
./scripts/config --disable CONFIG_NVME_TCP
./scripts/config --disable CONFIG_NVME_HOST_AUTH
./scripts/config --disable CONFIG_NVME_TARGET

#
# Misc devices
#
./scripts/config --enable CONFIG_RPMB
./scripts/config --disable CONFIG_ENCLOSURE_SERVICES
./scripts/config --module CONFIG_NTSYNC
./scripts/config --module CONFIG_NSM
./scripts/config --disable CONFIG_C2PORT

#
# EEPROM support
#
./scripts/config --module CONFIG_EEPROM_93XX46

# end of EEPROM support
./scripts/config --disable CONFIG_SENSORS_LIS3_I2C
./scripts/config --disable CONFIG_ALTERA_STAPL
./scripts/config --disable CONFIG_MISC_RTSX_USB

# end of SCSI device support
./scripts/config --disable CONFIG_ATA

./scripts/config --disable CONFIG_MD_RAID456
./scripts/config --disable CONFIG_DM_CLONE
./scripts/config --disable CONFIG_DM_RAID

./scripts/config --enable CONFIG_MII
./scripts/config --enable CONFIG_IPVLAN
./scripts/config --enable CONFIG_VXLAN

./scripts/config --disable CONFIG_NET_VENDOR_ALACRITECH
./scripts/config --disable CONFIG_NET_VENDOR_AMAZON
./scripts/config --disable CONFIG_NET_VENDOR_AQUANTIA
./scripts/config --disable CONFIG_NET_VENDOR_BROADCOM
./scripts/config --disable CONFIG_NET_VENDOR_CADENCE
./scripts/config --disable CONFIG_NET_VENDOR_CAVIUM
./scripts/config --disable CONFIG_NET_VENDOR_CIRRUS
./scripts/config --disable CONFIG_NET_VENDOR_CORTINA
./scripts/config --disable CONFIG_NET_VENDOR_EZCHIP
./scripts/config --disable CONFIG_NET_VENDOR_FARADAY
./scripts/config --disable CONFIG_NET_VENDOR_GOOGLE
./scripts/config --disable CONFIG_NET_VENDOR_HISILICON
./scripts/config --disable CONFIG_NET_VENDOR_HUAWEI
./scripts/config --disable CONFIG_NET_VENDOR_INTEL
./scripts/config --disable CONFIG_NET_VENDOR_MARVELL
./scripts/config --disable CONFIG_NET_VENDOR_MELLANOX
./scripts/config --disable CONFIG_NET_VENDOR_NI
./scripts/config --disable CONFIG_NET_VENDOR_NATSEMI
./scripts/config --disable CONFIG_NET_VENDOR_NETRONOME
./scripts/config --disable CONFIG_NET_VENDOR_PENSANDO
./scripts/config --disable CONFIG_NET_VENDOR_QUALCOMM
./scripts/config --disable CONFIG_NET_VENDOR_RENESAS
./scripts/config --disable CONFIG_NET_VENDOR_ROCKER
./scripts/config --disable CONFIG_NET_VENDOR_SAMSUNG
./scripts/config --disable CONFIG_NET_VENDOR_SOLARFLARE
./scripts/config --disable CONFIG_NET_VENDOR_SOCIONEXT
./scripts/config --disable CONFIG_NET_VENDOR_STMICRO
./scripts/config --disable CONFIG_NET_VENDOR_SYNOPSYS
./scripts/config --disable CONFIG_NET_VENDOR_VIA
./scripts/config --disable CONFIG_NET_VENDOR_XILINX

./scripts/config --module CONFIG_KS8851
./scripts/config --enable CONFIG_ENC28J60
./scripts/config --enable CONFIG_ENCX24J600

./scripts/config --enable CONFIG_NET_VENDOR_TI
./scripts/config --enable CONFIG_TI_DAVINCI_MDIO
./scripts/config --enable CONFIG_TI_CPSW_PHY_SEL
./scripts/config --enable CONFIG_TI_CPSW
./scripts/config --enable CONFIG_TI_CPSW_SWITCHDEV

./scripts/config --module CONFIG_WIZNET_W5100
./scripts/config --enable CONFIG_WIZNET_BUS_ANY
./scripts/config --module CONFIG_WIZNET_W5100_SPI

./scripts/config --enable CONFIG_PHYLIB
./scripts/config --enable CONFIG_FIXED_PHY
./scripts/config --disable CONFIG_SFP

#
# MII PHY device drivers
#
./scripts/config --disable CONFIG_AMD_PHY
./scripts/config --disable CONFIG_ADIN_PHY
./scripts/config --disable CONFIG_AQUANTIA_PHY
./scripts/config --disable CONFIG_BROADCOM_PHY

./scripts/config --disable CONFIG_BCM7XXX_PHY
./scripts/config --disable CONFIG_BCM87XX_PHY
./scripts/config --disable CONFIG_CICADA_PHY
./scripts/config --disable CONFIG_CORTINA_PHY
./scripts/config --disable CONFIG_DAVICOM_PHY
./scripts/config --disable CONFIG_ICPLUS_PHY
./scripts/config --disable CONFIG_LXT_PHY

./scripts/config --disable CONFIG_LSI_ET1011C_PHY
./scripts/config --disable CONFIG_MARVELL_PHY
./scripts/config --disable CONFIG_MARVELL_10G_PHY

./scripts/config --disable CONFIG_MICROCHIP_T1_PHY
./scripts/config --disable CONFIG_MICROCHIP_PHY_RDS_PTP
./scripts/config --disable CONFIG_NATIONAL_PHY

./scripts/config --disable CONFIG_QSEMI_PHY
./scripts/config --disable CONFIG_REALTEK_PHY
./scripts/config --disable CONFIG_RENESAS_PHY
./scripts/config --disable CONFIG_ROCKCHIP_PHY

./scripts/config --disable CONFIG_STE10XP
./scripts/config --disable CONFIG_TERANETICS_PHY
./scripts/config --disable CONFIG_DP83822_PHY
./scripts/config --disable CONFIG_DP83TC811_PHY
./scripts/config --disable CONFIG_DP83848_PHY
./scripts/config --disable CONFIG_DP83TD510_PHY

./scripts/config --enable CONFIG_MICREL_PHY
./scripts/config --enable CONFIG_MICROCHIP_PHY
./scripts/config --enable CONFIG_QCOM_NET_PHYLIB
./scripts/config --enable CONFIG_AT803X_PHY
./scripts/config --enable CONFIG_SMSC_PHY
./scripts/config --enable CONFIG_DP83867_PHY
./scripts/config --enable CONFIG_VITESSE_PHY

./scripts/config --disable CONFIG_CAN_FLEXCAN
./scripts/config --disable CONFIG_CAN_SJA1000
./scripts/config --disable CONFIG_CAN_SJA1000_ISA
./scripts/config --disable CONFIG_CAN_SOFTING

# end of CAN USB interfaces
./scripts/config --disable CONFIG_MDIO_BCM_UNIMAC
./scripts/config --enable CONFIG_MDIO_GPIO

#
# PCS device drivers
#
./scripts/config --disable CONFIG_PCS_XPCS

# end of PCS device drivers
./scripts/config --enable CONFIG_USB_NET_DRIVERS
./scripts/config --enable CONFIG_USB_USBNET
./scripts/config --enable CONFIG_USB_NET_SMSC95XX

./scripts/config --disable CONFIG_B43
./scripts/config --disable CONFIG_B43LEGACY
./scripts/config --disable CONFIG_BRCMSMAC
./scripts/config --disable CONFIG_LIBERTAS_SDIO

./scripts/config --disable CONFIG_MWIFIEX_SDIO
./scripts/config --module CONFIG_MWIFIEX_USB
./scripts/config --module CONFIG_WILC1000_SDIO
./scripts/config --module CONFIG_WILC1000_SPI

./scripts/config --module CONFIG_RTL8192DU

./scripts/config --disable CONFIG_RTW88_SDIO
./scripts/config --disable CONFIG_RTW88_8822BS
./scripts/config --disable CONFIG_RTW88_8822CS
./scripts/config --disable CONFIG_RTW88_8723DS
./scripts/config --disable CONFIG_RTW88_8723CS
./scripts/config --disable CONFIG_RTW88_8821CS

./scripts/config --module CONFIG_WFX

./scripts/config --disable CONFIG_IEEE802154_FAKELB

#
# Wireless WAN
#
./scripts/config --disable CONFIG_WWAN

#
# Userland interfaces
#
./scripts/config --disable CONFIG_INPUT_MOUSEDEV

./scripts/config --disable CONFIG_KEYBOARD_ATKBD
./scripts/config --disable CONFIG_KEYBOARD_OPENCORES
./scripts/config --disable CONFIG_KEYBOARD_OMAP4
./scripts/config --disable CONFIG_MOUSE_PS2

./scripts/config --module CONFIG_TOUCHSCREEN_AR1021_I2C
./scripts/config --module CONFIG_TOUCHSCREEN_ILI210X

./scripts/config --module CONFIG_INPUT_AD714X
./scripts/config --module CONFIG_INPUT_AD714X_I2C
./scripts/config --module CONFIG_INPUT_AD714X_SPI

./scripts/config --module CONFIG_INPUT_GPIO_BEEPER
./scripts/config --module CONFIG_INPUT_GPIO_DECODER

./scripts/config --enable CONFIG_INPUT_TPS65218_PWRBUTTON
./scripts/config --enable CONFIG_INPUT_TPS65219_PWRBUTTON

./scripts/config --disable CONFIG_INPUT_AXP20X_PEK
./scripts/config --disable CONFIG_INPUT_TWL4030_PWRBUTTON
./scripts/config --disable CONFIG_INPUT_TWL4030_VIBRA
./scripts/config --disable CONFIG_INPUT_TWL6040_VIBRA

./scripts/config --module CONFIG_INPUT_PWM_BEEPER

./scripts/config --disable CONFIG_INPUT_ADXL34X
./scripts/config --disable CONFIG_INPUT_ADXL34X_I2C
./scripts/config --disable CONFIG_INPUT_ADXL34X_SPI

#
# Hardware I/O ports
#
./scripts/config --disable CONFIG_SERIO_LIBPS2
./scripts/config --disable CONFIG_SERIO_ALTERA_PS2

#
# Character devices
#
./scripts/config --enable CONFIG_LEGACY_TIOCSTI

#
# Serial drivers
#
./scripts/config --disable CONFIG_SERIAL_8250_16550A_VARIANTS
./scripts/config --disable CONFIG_SERIAL_8250_DMA
./scripts/config --set-val CONFIG_SERIAL_8250_NR_UARTS 6
./scripts/config --set-val CONFIG_SERIAL_8250_RUNTIME_UARTS 6
./scripts/config --disable CONFIG_SERIAL_8250_EXTENDED
./scripts/config --disable CONFIG_SERIAL_8250_DW

./scripts/config --enable CONFIG_SERIAL_8250_OMAP
./scripts/config --enable CONFIG_SERIAL_8250_OMAP_TTYO_FIXUP

#
# Non-8250 serial port support
#
./scripts/config --module CONFIG_SERIAL_MAX3100
./scripts/config --module CONFIG_SERIAL_MAX310X
./scripts/config --disable CONFIG_SERIAL_ARC

# end of Serial drivers
./scripts/config --enable CONFIG_HW_RANDOM_OMAP
./scripts/config --disable CONFIG_HW_RANDOM_ARM_SMCCC_TRNG

#
# I2C support
#
./scripts/config --enable CONFIG_I2C_CHARDEV
./scripts/config --enable CONFIG_I2C_MUX

#
# Multiplexer I2C Chip support
#
./scripts/config --enable CONFIG_I2C_MUX_GPIO
./scripts/config --enable CONFIG_I2C_MUX_PINCTRL
./scripts/config --module CONFIG_I2C_MUX_REG

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
./scripts/config --disable CONFIG_I2C_DESIGNWARE_CORE
./scripts/config --disable CONFIG_I2C_OCORES
./scripts/config --disable CONFIG_I2C_PCA_PLATFORM
./scripts/config --disable CONFIG_I2C_RK3X
./scripts/config --disable CONFIG_I2C_SIMTEC

# end of I2C Hardware Bus support
./scripts/config --disable CONFIG_I2C_FSI
./scripts/config --module CONFIG_I2C_STUB
./scripts/config --enable CONFIG_I2C_SLAVE_EEPROM

#
# SPI Master Controller Drivers
#
./scripts/config --disable CONFIG_SPI_ALTERA
./scripts/config --disable CONFIG_SPI_CADENCE_QUADSPI
./scripts/config --enable CONFIG_SPI_OMAP24XX
./scripts/config --disable CONFIG_SPI_TI_QSPI
./scripts/config --disable CONFIG_SPI_PL022

#
# SPI Protocol Masters
#
./scripts/config --module CONFIG_SPI_SPIDEV
./scripts/config --enable CONFIG_SPI_SLAVE
./scripts/config --module CONFIG_SPI_SLAVE_TIME
./scripts/config --module CONFIG_SPI_SLAVE_SYSTEM_CONTROL

#
# SPI Offload triggers
#
./scripts/config --module CONFIG_SPI_OFFLOAD_TRIGGER_PWM
./scripts/config --disable CONFIG_HSI

#
# PPS clients support
#
./scripts/config --module CONFIG_PPS_GENERATOR

# end of PTP clock support
./scripts/config --disable CONFIG_PINCTRL_AS3722
./scripts/config --disable CONFIG_PINCTRL_AXP209
./scripts/config --disable CONFIG_PINCTRL_PALMAS
./scripts/config --disable CONFIG_PINCTRL_RK805

#
# Memory mapped GPIO drivers
#
./scripts/config --disable CONFIG_GPIO_ALTERA
./scripts/config --disable CONFIG_GPIO_DWAPB
./scripts/config --disable CONFIG_GPIO_PL061
./scripts/config --enable CONFIG_GPIO_SYSCON

#
# I2C GPIO expanders
#
./scripts/config --module CONFIG_GPIO_ADNP
./scripts/config --module CONFIG_GPIO_MAX7300
./scripts/config --module CONFIG_GPIO_MAX732X
./scripts/config --module CONFIG_GPIO_PCA9570
./scripts/config --module CONFIG_GPIO_PCF857X
./scripts/config --module CONFIG_GPIO_TPIC2810

#
# SPI GPIO expanders
#
./scripts/config --module CONFIG_GPIO_74X164
./scripts/config --module CONFIG_GPIO_MAX3191X
./scripts/config --module CONFIG_GPIO_MAX7301
./scripts/config --module CONFIG_GPIO_MC33880
./scripts/config --module CONFIG_GPIO_PISOSR
./scripts/config --module CONFIG_GPIO_XRA1403

#
# USB GPIO expanders
#
./scripts/config --disable CONFIG_GPIO_MPSSE

#
# MFD GPIO expanders
#
./scripts/config --enable CONFIG_GPIO_TPS65219

#
# Virtual GPIO drivers
#
./scripts/config --enable CONFIG_GPIO_AGGREGATOR

# end of GPIO Debugging utilities
./scripts/config --enable CONFIG_W1

#
# 1-wire Slaves
#
./scripts/config --module CONFIG_W1_SLAVE_DS2430
./scripts/config --enable CONFIG_W1_SLAVE_DS2433_CRC
./scripts/config --module CONFIG_W1_SLAVE_DS250X

# end of 1-wire Slaves
./scripts/config --enable CONFIG_POWER_SEQUENCING
./scripts/config --enable CONFIG_GENERIC_ADC_BATTERY

./scripts/config --disable CONFIG_BATTERY_SBS
./scripts/config --disable CONFIG_BATTERY_BQ27XXX
./scripts/config --disable CONFIG_CHARGER_AXP20X
./scripts/config --disable CONFIG_BATTERY_AXP20X
./scripts/config --disable CONFIG_AXP20X_POWER
./scripts/config --disable CONFIG_CHARGER_BQ24735
./scripts/config --disable CONFIG_CHARGER_ISP1704

./scripts/config --module CONFIG_CHARGER_BQ25890

#
# Native drivers
#
./scripts/config --module CONFIG_SENSORS_AD7314
./scripts/config --module CONFIG_SENSORS_ADM1025
./scripts/config --module CONFIG_SENSORS_ADM1026
./scripts/config --module CONFIG_SENSORS_ADM1031
./scripts/config --module CONFIG_SENSORS_ADM1177
./scripts/config --module CONFIG_SENSORS_ADT7X10
./scripts/config --module CONFIG_SENSORS_ADT7310
./scripts/config --module CONFIG_SENSORS_ADT7410
./scripts/config --module CONFIG_SENSORS_AHT10
./scripts/config --module CONFIG_SENSORS_AQUACOMPUTER_D5NEXT
./scripts/config --module CONFIG_SENSORS_AXI_FAN_CONTROL
./scripts/config --module CONFIG_SENSORS_CORSAIR_CPRO
./scripts/config --module CONFIG_SENSORS_CORSAIR_PSU
./scripts/config --module CONFIG_SENSORS_AS370
./scripts/config --module CONFIG_SENSORS_DS1621
./scripts/config --module CONFIG_SENSORS_F71805F
./scripts/config --module CONFIG_SENSORS_GL518SM
./scripts/config --module CONFIG_SENSORS_GL520SM
./scripts/config --enable CONFIG_SENSORS_GPIO_FAN
./scripts/config --module CONFIG_SENSORS_HIH6130
./scripts/config --module CONFIG_SENSORS_HTU31
./scripts/config --module CONFIG_SENSORS_ISL28022
./scripts/config --module CONFIG_SENSORS_IT87
./scripts/config --module CONFIG_SENSORS_POWR1220
./scripts/config --module CONFIG_SENSORS_LTC2945
./scripts/config --module CONFIG_SENSORS_LTC2947
./scripts/config --module CONFIG_SENSORS_LTC2947_I2C
./scripts/config --module CONFIG_SENSORS_LTC2947_SPI
./scripts/config --module CONFIG_SENSORS_LTC2990
./scripts/config --module CONFIG_SENSORS_LTC2992
./scripts/config --module CONFIG_SENSORS_LTC4222
./scripts/config --module CONFIG_SENSORS_LTC4260
./scripts/config --module CONFIG_SENSORS_MAX127
./scripts/config --module CONFIG_SENSORS_MAX1619
./scripts/config --module CONFIG_SENSORS_MAX197
./scripts/config --module CONFIG_SENSORS_MAX31722
./scripts/config --module CONFIG_SENSORS_MAX31730
./scripts/config --module CONFIG_SENSORS_MAX31760
./scripts/config --module CONFIG_SENSORS_MAX6620
./scripts/config --module CONFIG_SENSORS_MAX6621
./scripts/config --module CONFIG_SENSORS_MAX6697
./scripts/config --module CONFIG_SENSORS_MAX31790
./scripts/config --module CONFIG_SENSORS_MC34VR500
./scripts/config --module CONFIG_SENSORS_MCP3021
./scripts/config --module CONFIG_SENSORS_TC654
./scripts/config --module CONFIG_SENSORS_TPS23861
./scripts/config --module CONFIG_SENSORS_MR75203
./scripts/config --module CONFIG_SENSORS_LM63
./scripts/config --module CONFIG_SENSORS_LM77
./scripts/config --module CONFIG_SENSORS_LM78
./scripts/config --module CONFIG_SENSORS_LM80
./scripts/config --module CONFIG_SENSORS_LM83
./scripts/config --module CONFIG_SENSORS_LM85
./scripts/config --module CONFIG_SENSORS_LM87
./scripts/config --module CONFIG_SENSORS_LM92
./scripts/config --module CONFIG_SENSORS_LM95234
./scripts/config --module CONFIG_SENSORS_PC87360
./scripts/config --module CONFIG_SENSORS_NCT6775_CORE
./scripts/config --module CONFIG_SENSORS_NCT6775_I2C
./scripts/config --module CONFIG_SENSORS_NCT7363
./scripts/config --module CONFIG_SENSORS_NZXT_KRAKEN2
./scripts/config --module CONFIG_SENSORS_NZXT_KRAKEN3
./scripts/config --module CONFIG_SENSORS_NZXT_SMART2
./scripts/config --module CONFIG_SENSORS_OCC_P8_I2C
./scripts/config --module CONFIG_SENSORS_PCF8591
./scripts/config --module CONFIG_SENSORS_ACBEL_FSG032
./scripts/config --module CONFIG_SENSORS_ADM1266
./scripts/config --module CONFIG_SENSORS_ADM1275
./scripts/config --module CONFIG_SENSORS_ADP1050
./scripts/config --module CONFIG_SENSORS_BEL_PFE
./scripts/config --module CONFIG_SENSORS_BPA_RS600
./scripts/config --module CONFIG_SENSORS_CRPS
./scripts/config --module CONFIG_SENSORS_DELTA_AHE50DC_FAN
./scripts/config --module CONFIG_SENSORS_FSP_3Y
./scripts/config --module CONFIG_SENSORS_DPS920AB
./scripts/config --module CONFIG_SENSORS_INA233
./scripts/config --module CONFIG_SENSORS_INSPUR_IPSPS
./scripts/config --module CONFIG_SENSORS_IR35221
./scripts/config --module CONFIG_SENSORS_IR36021
./scripts/config --module CONFIG_SENSORS_IR38064
./scripts/config --enable CONFIG_SENSORS_IR38064_REGULATOR
./scripts/config --module CONFIG_SENSORS_IRPS5401
./scripts/config --module CONFIG_SENSORS_ISL68137
./scripts/config --module CONFIG_SENSORS_LM25066
./scripts/config --enable CONFIG_SENSORS_LM25066_REGULATOR
./scripts/config --module CONFIG_SENSORS_LT7182S
./scripts/config --module CONFIG_SENSORS_LTC2978
./scripts/config --enable CONFIG_SENSORS_LTC2978_REGULATOR
./scripts/config --module CONFIG_SENSORS_LTC3815
./scripts/config --module CONFIG_SENSORS_MAX15301
./scripts/config --module CONFIG_SENSORS_MAX16064
./scripts/config --module CONFIG_SENSORS_MAX16601
./scripts/config --module CONFIG_SENSORS_MAX20730
./scripts/config --module CONFIG_SENSORS_MAX20751
./scripts/config --module CONFIG_SENSORS_MAX31785
./scripts/config --module CONFIG_SENSORS_MAX34440
./scripts/config --module CONFIG_SENSORS_MAX8688
./scripts/config --module CONFIG_SENSORS_MP2856
./scripts/config --module CONFIG_SENSORS_MP2888
./scripts/config --module CONFIG_SENSORS_MP2891
./scripts/config --module CONFIG_SENSORS_MP2975
./scripts/config --module CONFIG_SENSORS_MP2993
./scripts/config --module CONFIG_SENSORS_MP5023
./scripts/config --module CONFIG_SENSORS_MP5920
./scripts/config --module CONFIG_SENSORS_MP5990
./scripts/config --module CONFIG_SENSORS_MP9941
./scripts/config --module CONFIG_SENSORS_MPQ7932
./scripts/config --module CONFIG_SENSORS_MPQ8785
./scripts/config --module CONFIG_SENSORS_PIM4328
./scripts/config --module CONFIG_SENSORS_PLI1209BC
./scripts/config --enable CONFIG_SENSORS_PLI1209BC_REGULATOR
./scripts/config --module CONFIG_SENSORS_PM6764TR
./scripts/config --module CONFIG_SENSORS_PXE1610
./scripts/config --module CONFIG_SENSORS_Q54SJ108A2
./scripts/config --module CONFIG_SENSORS_STPDDC60
./scripts/config --module CONFIG_SENSORS_TDA38640
./scripts/config --module CONFIG_SENSORS_TPS25990
./scripts/config --enable CONFIG_SENSORS_TPS25990_REGULATOR
./scripts/config --module CONFIG_SENSORS_TPS40422
./scripts/config --module CONFIG_SENSORS_TPS53679
./scripts/config --module CONFIG_SENSORS_TPS546D24
./scripts/config --module CONFIG_SENSORS_UCD9000
./scripts/config --module CONFIG_SENSORS_UCD9200
./scripts/config --module CONFIG_SENSORS_XDP710
./scripts/config --module CONFIG_SENSORS_XDPE152
./scripts/config --module CONFIG_SENSORS_XDPE122
./scripts/config --enable CONFIG_SENSORS_XDPE122_REGULATOR
./scripts/config --module CONFIG_SENSORS_ZL6100
./scripts/config --module CONFIG_SENSORS_PT5161L
./scripts/config --module CONFIG_SENSORS_SBTSI
./scripts/config --module CONFIG_SENSORS_SHT15
./scripts/config --module CONFIG_SENSORS_SHTC1
./scripts/config --module CONFIG_SENSORS_SIS5595
./scripts/config --module CONFIG_SENSORS_EMC2305
./scripts/config --module CONFIG_SENSORS_SMSC47M1
./scripts/config --module CONFIG_SENSORS_SMSC47B397
./scripts/config --module CONFIG_SENSORS_SCH5636
./scripts/config --module CONFIG_SENSORS_STTS751
./scripts/config --module CONFIG_SENSORS_ADC128D818
./scripts/config --module CONFIG_SENSORS_INA209
./scripts/config --module CONFIG_SENSORS_INA2XX
./scripts/config --module CONFIG_SENSORS_INA238
./scripts/config --module CONFIG_SENSORS_INA3221
./scripts/config --module CONFIG_SENSORS_TC74
./scripts/config --module CONFIG_SENSORS_TMP103
./scripts/config --module CONFIG_SENSORS_TMP108
./scripts/config --module CONFIG_SENSORS_TMP464
./scripts/config --module CONFIG_SENSORS_TMP513
./scripts/config --module CONFIG_SENSORS_W83781D
./scripts/config --enable CONFIG_SENSORS_W83795_FANCTRL
./scripts/config --module CONFIG_SENSORS_W83L785TS
./scripts/config --module CONFIG_SENSORS_W83627HF

#
# Texas Instruments thermal drivers
#
./scripts/config --module CONFIG_GENERIC_ADC_THERMAL

#
# Watchdog Device Drivers
#
./scripts/config --enable CONFIG_SOFT_WATCHDOG
./scripts/config --disable CONFIG_DW_WATCHDOG
./scripts/config --enable CONFIG_OMAP_WATCHDOG

#
# USB-based Watchdog Cards
#
./scripts/config --disable CONFIG_SSB
./scripts/config --disable CONFIG_BCMA

#
# Multifunction device drivers
#
./scripts/config --disable CONFIG_MFD_AS3722
./scripts/config --disable CONFIG_MFD_AXP20X
./scripts/config --disable CONFIG_MFD_AXP20X_I2C
./scripts/config --disable CONFIG_PMIC_DA9052
./scripts/config --disable CONFIG_MFD_DA9052_SPI
./scripts/config --disable CONFIG_MFD_DA9052_I2C
./scripts/config --disable CONFIG_MFD_MC13XXX
./scripts/config --disable CONFIG_MFD_MC13XXX_SPI
./scripts/config --disable CONFIG_MFD_MC13XXX_I2C
./scripts/config --disable CONFIG_MFD_MAX77686
./scripts/config --disable CONFIG_MFD_VIPERBOARD
./scripts/config --disable CONFIG_MFD_RK8XX
./scripts/config --disable CONFIG_MFD_RK8XX_I2C
./scripts/config --disable CONFIG_MFD_RN5T618
./scripts/config --disable CONFIG_MFD_STMPE
./scripts/config --disable CONFIG_MFD_PALMAS
./scripts/config --disable CONFIG_TWL4030_CORE
./scripts/config --disable CONFIG_TWL6040_CORE
./scripts/config --disable CONFIG_MFD_WM8994
./scripts/config --disable CONFIG_MFD_STPMIC1
./scripts/config --disable CONFIG_MFD_SEC_CORE

./scripts/config --enable CONFIG_MFD_TI_AM335X_TSCADC
./scripts/config --enable CONFIG_MFD_TPS65217
./scripts/config --enable CONFIG_MFD_TPS65219

# end of Multifunction device drivers
./scripts/config --disable CONFIG_REGULATOR_ACT8865
./scripts/config --disable CONFIG_REGULATOR_AXP20X
./scripts/config --disable CONFIG_REGULATOR_DA9052
./scripts/config --disable CONFIG_REGULATOR_FAN53555
./scripts/config --disable CONFIG_REGULATOR_MC13XXX_CORE
./scripts/config --disable CONFIG_REGULATOR_MC13783
./scripts/config --disable CONFIG_REGULATOR_MC13892
./scripts/config --disable CONFIG_REGULATOR_PFUZE100
./scripts/config --disable CONFIG_REGULATOR_RK808
./scripts/config --disable CONFIG_REGULATOR_SY8106A

./scripts/config --enable CONFIG_REGULATOR_USERSPACE_CONSUMER
./scripts/config --enable CONFIG_REGULATOR_GPIO
./scripts/config --enable CONFIG_REGULATOR_PBIAS
./scripts/config --enable CONFIG_REGULATOR_PWM
./scripts/config --module CONFIG_REGULATOR_RASPBERRYPI_TOUCHSCREEN_ATTINY
./scripts/config --enable CONFIG_REGULATOR_TI_ABB
./scripts/config --enable CONFIG_REGULATOR_TPS65217
./scripts/config --enable CONFIG_REGULATOR_TPS65219

#
# CEC support
#
./scripts/config --enable CONFIG_CEC_NXP_TDA9950

#
# MMC/SDIO DVB adapters
#
./scripts/config --disable CONFIG_V4L_TEST_DRIVERS

#
# Graphics support
#
./scripts/config --enable CONFIG_AUXDISPLAY
./scripts/config --module CONFIG_HD44780
./scripts/config --module CONFIG_LCD2S
./scripts/config --module CONFIG_IMG_ASCII_LCD
./scripts/config --module CONFIG_HT16K33
./scripts/config --module CONFIG_SEG_LED_GPIO
./scripts/config --enable CONFIG_DRM
./scripts/config --enable CONFIG_DRM_KMS_HELPER

# end of Supported DRM clients
./scripts/config --enable CONFIG_DRM_DISPLAY_DP_AUX_BUS
./scripts/config --enable CONFIG_DRM_DISPLAY_HELPER
./scripts/config --enable CONFIG_DRM_GEM_DMA_HELPER

#
# Drivers for system framebuffers
#
./scripts/config --enable CONFIG_DRM_SIMPLEDRM

# end of ARM devices
./scripts/config --disable CONFIG_DRM_ARMADA
./scripts/config --disable CONFIG_DRM_OMAP
./scripts/config --enable CONFIG_DRM_TILCDC
./scripts/config --disable CONFIG_DRM_VIRTIO_GPU

#
# Display Panels
#
./scripts/config --enable CONFIG_DRM_PANEL_EDP
./scripts/config --enable CONFIG_DRM_PANEL_SIMPLE

#
# Display Interface Bridges
#
./scripts/config --enable CONFIG_DRM_DISPLAY_CONNECTOR
./scripts/config --enable CONFIG_DRM_I2C_NXP_TDA998X
./scripts/config --enable CONFIG_DRM_ITE_IT66121
./scripts/config --disable CONFIG_DRM_SAMSUNG_DSIM
./scripts/config --enable CONFIG_DRM_TI_TFP410

# end of Display Interface Bridges
./scripts/config --disable CONFIG_DRM_ETNAVIV

./scripts/config --module CONFIG_DRM_GM12U320
./scripts/config --module CONFIG_TINYDRM_HX8357D
./scripts/config --module CONFIG_TINYDRM_ILI9163
./scripts/config --module CONFIG_TINYDRM_ILI9225
./scripts/config --module CONFIG_TINYDRM_ILI9341
./scripts/config --module CONFIG_TINYDRM_ILI9486
./scripts/config --module CONFIG_TINYDRM_MI0283QT
./scripts/config --module CONFIG_TINYDRM_REPAPER
./scripts/config --module CONFIG_TINYDRM_SHARP_MEMORY
./scripts/config --module CONFIG_TINYDRM_ST7586
./scripts/config --module CONFIG_TINYDRM_ST7735R

./scripts/config --disable CONFIG_DRM_LIMA
./scripts/config --disable CONFIG_DRM_PANFROST

#
# Frame buffer Devices
#
./scripts/config --disable CONFIG_FB_EFI
./scripts/config --module CONFIG_FB_SSD1307

#
# Backlight & LCD device support
#
./scripts/config --enable CONFIG_BACKLIGHT_PWM
./scripts/config --enable CONFIG_BACKLIGHT_TPS65217
./scripts/config --enable CONFIG_BACKLIGHT_GPIO
./scripts/config --enable CONFIG_BACKLIGHT_LED

#
# Console display driver support
#
./scripts/config --enable CONFIG_FRAMEBUFFER_CONSOLE_LEGACY_ACCELERATION

# end of Console display driver support
./scripts/config --enable CONFIG_LOGO
./scripts/config --enable CONFIG_LOGO_LINUX_MONO
./scripts/config --enable CONFIG_LOGO_LINUX_VGA16
./scripts/config --disable CONFIG_LOGO_LINUX_CLUT224
./scripts/config --enable CONFIG_LOGO_BEAGLE_CLUT224

# end of Graphics support
./scripts/config --enable CONFIG_SOUND_OSS_CORE_PRECLAIM
./scripts/config --module CONFIG_SND_DUMMY
./scripts/config --module CONFIG_SND_VIRMIDI
./scripts/config --module CONFIG_SND_MTPAV
./scripts/config --module CONFIG_SND_SERIAL_U16550
./scripts/config --module CONFIG_SND_MPU401

#
# Common SoC Audio options for Freescale CPUs:
#
./scripts/config --disable CONFIG_SND_SOC_FSL_SAI
./scripts/config --disable CONFIG_SND_SOC_FSL_SSI
./scripts/config --disable CONFIG_SND_SOC_FSL_SPDIF
./scripts/config --disable CONFIG_SND_SOC_FSL_ESAI
./scripts/config --disable CONFIG_SND_SOC_IMX_AUDMUX

#
# CODEC drivers
#
./scripts/config --module CONFIG_SND_SOC_ADAU1701
./scripts/config --module CONFIG_SND_SOC_ADAU7002
./scripts/config --module CONFIG_SND_SOC_AK4554
./scripts/config --module CONFIG_SND_SOC_CS4265
./scripts/config --module CONFIG_SND_SOC_CS4271
./scripts/config --module CONFIG_SND_SOC_CS4271_I2C
./scripts/config --module CONFIG_SND_SOC_DMIC
./scripts/config --module CONFIG_SND_SOC_ES8316
./scripts/config --module CONFIG_SND_SOC_MAX98357A
./scripts/config --module CONFIG_SND_SOC_PCM3168A
./scripts/config --module CONFIG_SND_SOC_PCM3168A_I2C
./scripts/config --module CONFIG_SND_SOC_PCM512x
./scripts/config --module CONFIG_SND_SOC_PCM512x_I2C
./scripts/config --module CONFIG_SND_SOC_SIGMADSP
./scripts/config --module CONFIG_SND_SOC_SIGMADSP_I2C
./scripts/config --module CONFIG_SND_SOC_SIMPLE_AMPLIFIER
./scripts/config --module CONFIG_SND_SOC_TLV320AIC3X
./scripts/config --module CONFIG_SND_SOC_TLV320AIC3X_I2C
./scripts/config --module CONFIG_SND_SOC_WM8904
./scripts/config --module CONFIG_SND_SOC_WM8960

# end of CODEC drivers
./scripts/config --enable CONFIG_HID
./scripts/config --enable CONFIG_UHID
./scripts/config --enable CONFIG_HID_GENERIC

# end of HID-BPF support
./scripts/config --enable CONFIG_I2C_HID

#
# USB HID support
#
./scripts/config --enable CONFIG_USB_HID

# end of USB HID support
./scripts/config --enable CONFIG_USB_COMMON
./scripts/config --disable CONFIG_USB_ULPI_BUS
./scripts/config --disable CONFIG_USB_CONN_GPIO
./scripts/config --enable CONFIG_USB

#
# Miscellaneous USB options
#
./scripts/config --enable CONFIG_USB_OTG

#
# USB Host Controller Drivers
#
./scripts/config --disable CONFIG_USB_XHCI_HCD
./scripts/config --disable CONFIG_USB_EHCI_HCD
./scripts/config --disable CONFIG_USB_OHCI_HCD

#
# USB dual-mode controller drivers
#
./scripts/config --enable CONFIG_USB_MUSB_HDRC
./scripts/config --disable CONFIG_USB_MUSB_HOST
./scripts/config --disable CONFIG_USB_MUSB_GADGET
./scripts/config --enable CONFIG_USB_MUSB_DUAL_ROLE

#
# Platform Glue Layer
#
./scripts/config --disable CONFIG_USB_MUSB_TUSB6010
./scripts/config --disable CONFIG_USB_MUSB_OMAP2PLUS
./scripts/config --enable CONFIG_USB_MUSB_DSPS

#
# MUSB DMA mode
#
./scripts/config --enable CONFIG_MUSB_PIO_ONLY
./scripts/config --disable CONFIG_USB_DWC3
./scripts/config --disable CONFIG_USB_DWC2
./scripts/config --disable CONFIG_USB_CHIPIDEA

#
# USB Miscellaneous drivers
#
./scripts/config --enable CONFIG_USB_ONBOARD_DEV

#
# USB Physical Layer drivers
#
./scripts/config --enable CONFIG_NOP_USB_XCEIV
./scripts/config --enable CONFIG_AM335X_CONTROL_USB
./scripts/config --enable CONFIG_AM335X_PHY_USB
./scripts/config --enable CONFIG_USB_GPIO_VBUS
./scripts/config --disable CONFIG_USB_ULPI

# end of USB Physical Layer drivers
./scripts/config --enable CONFIG_USB_GADGET
./scripts/config --set-val CONFIG_USB_GADGET_VBUS_DRAW 500

#
# USB Peripheral Controller
#
./scripts/config --enable CONFIG_USB_LIBCOMPOSITE
./scripts/config --enable CONFIG_USB_F_ACM
./scripts/config --enable CONFIG_USB_F_SS_LB
./scripts/config --enable CONFIG_USB_U_SERIAL
./scripts/config --enable CONFIG_USB_U_ETHER
./scripts/config --enable CONFIG_USB_F_SERIAL
./scripts/config --enable CONFIG_USB_F_OBEX
./scripts/config --enable CONFIG_USB_F_NCM
./scripts/config --enable CONFIG_USB_F_ECM
./scripts/config --enable CONFIG_USB_F_EEM
./scripts/config --enable CONFIG_USB_F_SUBSET
./scripts/config --enable CONFIG_USB_F_RNDIS
./scripts/config --enable CONFIG_USB_F_MASS_STORAGE
./scripts/config --enable CONFIG_USB_F_FS
./scripts/config --enable CONFIG_USB_F_HID
./scripts/config --enable CONFIG_USB_F_PRINTER
./scripts/config --enable CONFIG_USB_CONFIGFS

# end of USB Gadget precomposed configurations
./scripts/config --disable CONFIG_TYPEC
./scripts/config --disable CONFIG_USB_ROLE_SWITCH
./scripts/config --disable CONFIG_PWRSEQ_SD8787

#
# MMC/SD/SDIO Host Controller Drivers
#
./scripts/config --enable CONFIG_MMC_SDHCI
./scripts/config --enable CONFIG_MMC_SDHCI_PLTFM
./scripts/config --disable CONFIG_MMC_OMAP
./scripts/config --enable CONFIG_MMC_OMAP_HS
./scripts/config --enable CONFIG_MMC_SPI
./scripts/config --disable CONFIG_MMC_DW
./scripts/config --disable CONFIG_MMC_CQHCI
./scripts/config --enable CONFIG_MMC_SDHCI_OMAP
./scripts/config --disable CONFIG_MEMSTICK

#
# LED drivers
#
./scripts/config --module CONFIG_LEDS_LM3692X
./scripts/config --module CONFIG_LEDS_PCA9532
./scripts/config --enable CONFIG_LEDS_GPIO
./scripts/config --module CONFIG_LEDS_LP55XX_COMMON
./scripts/config --enable CONFIG_LEDS_PWM
./scripts/config --enable CONFIG_LEDS_TLC591XX
./scripts/config --enable CONFIG_LEDS_SYSCON

#
# RGB LED drivers
#
./scripts/config --module CONFIG_LEDS_GROUP_MULTICOLOR
./scripts/config --module CONFIG_LEDS_PWM_MULTICOLOR

#
# LED Triggers
#
./scripts/config --enable CONFIG_LEDS_TRIGGER_TIMER
./scripts/config --enable CONFIG_LEDS_TRIGGER_ONESHOT
./scripts/config --enable CONFIG_LEDS_TRIGGER_BACKLIGHT
./scripts/config --enable CONFIG_LEDS_TRIGGER_ACTIVITY
./scripts/config --enable CONFIG_LEDS_TRIGGER_DEFAULT_ON

#
# Simatic LED drivers
#
./scripts/config --disable CONFIG_ACCESSIBILITY
./scripts/config --disable CONFIG_INFINIBAND


#
# I2C RTC drivers
#
./scripts/config --enable CONFIG_RTC_DRV_ABB5ZES3
./scripts/config --enable CONFIG_RTC_DRV_ABEOZ9
./scripts/config --enable CONFIG_RTC_DRV_ABX80X
./scripts/config --enable CONFIG_RTC_DRV_DS1374
./scripts/config --enable CONFIG_RTC_DRV_DS1374_WDT
./scripts/config --enable CONFIG_RTC_DRV_DS1672
./scripts/config --enable CONFIG_RTC_DRV_HYM8563
./scripts/config --enable CONFIG_RTC_DRV_MAX6900
./scripts/config --enable CONFIG_RTC_DRV_NCT3018Y
./scripts/config --enable CONFIG_RTC_DRV_RS5C372
./scripts/config --enable CONFIG_RTC_DRV_ISL1208
./scripts/config --enable CONFIG_RTC_DRV_ISL12022
./scripts/config --enable CONFIG_RTC_DRV_ISL12026
./scripts/config --enable CONFIG_RTC_DRV_X1205
./scripts/config --enable CONFIG_RTC_DRV_PCF85063
./scripts/config --enable CONFIG_RTC_DRV_PCF85363
./scripts/config --enable CONFIG_RTC_DRV_PCF8583
./scripts/config --enable CONFIG_RTC_DRV_M41T80
./scripts/config --enable CONFIG_RTC_DRV_M41T80_WDT
./scripts/config --enable CONFIG_RTC_DRV_BQ32K
./scripts/config --enable CONFIG_RTC_DRV_S35390A
./scripts/config --enable CONFIG_RTC_DRV_FM3130
./scripts/config --enable CONFIG_RTC_DRV_RX8010
./scripts/config --enable CONFIG_RTC_DRV_RX8581
./scripts/config --enable CONFIG_RTC_DRV_RX8025
./scripts/config --enable CONFIG_RTC_DRV_EM3027
./scripts/config --module CONFIG_RTC_DRV_RV3028
./scripts/config --enable CONFIG_RTC_DRV_RV8803

#
# SPI RTC drivers
#
./scripts/config --enable CONFIG_RTC_DRV_M41T93
./scripts/config --enable CONFIG_RTC_DRV_M41T94
./scripts/config --enable CONFIG_RTC_DRV_DS1302
./scripts/config --enable CONFIG_RTC_DRV_DS1305
./scripts/config --enable CONFIG_RTC_DRV_DS1343
./scripts/config --enable CONFIG_RTC_DRV_DS1347
./scripts/config --enable CONFIG_RTC_DRV_DS1390
./scripts/config --enable CONFIG_RTC_DRV_MAX6916
./scripts/config --enable CONFIG_RTC_DRV_R9701
./scripts/config --enable CONFIG_RTC_DRV_RX4581
./scripts/config --enable CONFIG_RTC_DRV_RS5C348
./scripts/config --enable CONFIG_RTC_DRV_MAX6902
./scripts/config --enable CONFIG_RTC_DRV_PCF2123
./scripts/config --enable CONFIG_RTC_DRV_MCP795

#
# SPI and I2C RTC drivers
#
./scripts/config --enable CONFIG_RTC_DRV_DS3232
./scripts/config --enable CONFIG_RTC_DRV_DS3232_HWMON
./scripts/config --enable CONFIG_RTC_DRV_PCF2127
./scripts/config --enable CONFIG_RTC_DRV_RV3029C2
./scripts/config --enable CONFIG_RTC_DRV_RV3029_HWMON
./scripts/config --enable CONFIG_RTC_DRV_RX6110

#
# Platform RTC drivers
#
./scripts/config --module CONFIG_RTC_DRV_DS1286
./scripts/config --module CONFIG_RTC_DRV_DS1511
./scripts/config --module CONFIG_RTC_DRV_DS1553
./scripts/config --module CONFIG_RTC_DRV_DS1685_FAMILY
./scripts/config --enable CONFIG_RTC_DRV_DS1685
./scripts/config --module CONFIG_RTC_DRV_DS1742
./scripts/config --module CONFIG_RTC_DRV_DS2404
./scripts/config --module CONFIG_RTC_DRV_STK17TA8
./scripts/config --module CONFIG_RTC_DRV_M48T86
./scripts/config --module CONFIG_RTC_DRV_M48T35
./scripts/config --module CONFIG_RTC_DRV_M48T59
./scripts/config --module CONFIG_RTC_DRV_MSM6242
./scripts/config --module CONFIG_RTC_DRV_RP5C01

#
# HID Sensor RTC drivers
#
./scripts/config --module CONFIG_RTC_DRV_HID_SENSOR_TIME

#
# DMA Devices
#
./scripts/config --enable CONFIG_TI_CPPI41

#
# DMABUF options
#
./scripts/config --enable CONFIG_UDMABUF
./scripts/config --enable CONFIG_DMABUF_HEAPS
./scripts/config --enable CONFIG_DMABUF_HEAPS_SYSTEM
./scripts/config --enable CONFIG_DMABUF_HEAPS_CMA

# end of DMABUF options
./scripts/config --module CONFIG_UIO_PDRV_GENIRQ
./scripts/config --disable CONFIG_VFIO
./scripts/config --disable CONFIG_VDPA

# end of Microsoft Hyper-V guest support
./scripts/config --module CONFIG_GREYBUS
./scripts/config --module CONFIG_GREYBUS_ES2

#
# Accelerometers
#
./scripts/config --module CONFIG_ADIS16203

#
# Analog to digital converters
#
./scripts/config --module CONFIG_AD7816

#
# Analog digital bi-direction converters
#
./scripts/config --module CONFIG_ADT7316
./scripts/config --module CONFIG_ADT7316_SPI
./scripts/config --module CONFIG_ADT7316_I2C

#
# Direct Digital Synthesis
#
./scripts/config --module CONFIG_AD9832
./scripts/config --module CONFIG_AD9834

#
# Network Analyzer, Impedance Converters
#
./scripts/config --module CONFIG_AD5933

#
# StarFive media platform drivers
#
./scripts/config --module CONFIG_FB_TFT
./scripts/config --module CONFIG_FB_TFT_AGM1264K_FL
./scripts/config --module CONFIG_FB_TFT_BD663474
./scripts/config --module CONFIG_FB_TFT_HX8340BN
./scripts/config --module CONFIG_FB_TFT_HX8347D
./scripts/config --module CONFIG_FB_TFT_HX8353D
./scripts/config --module CONFIG_FB_TFT_HX8357D
./scripts/config --module CONFIG_FB_TFT_ILI9163
./scripts/config --module CONFIG_FB_TFT_ILI9320
./scripts/config --module CONFIG_FB_TFT_ILI9325
./scripts/config --module CONFIG_FB_TFT_ILI9340
./scripts/config --module CONFIG_FB_TFT_ILI9341
./scripts/config --module CONFIG_FB_TFT_ILI9481
./scripts/config --module CONFIG_FB_TFT_ILI9486
./scripts/config --module CONFIG_FB_TFT_PCD8544
./scripts/config --module CONFIG_FB_TFT_RA8875
./scripts/config --module CONFIG_FB_TFT_S6D02A1
./scripts/config --module CONFIG_FB_TFT_S6D1121
./scripts/config --module CONFIG_FB_TFT_SEPS525
./scripts/config --module CONFIG_FB_TFT_SH1106
./scripts/config --module CONFIG_FB_TFT_SSD1289
./scripts/config --module CONFIG_FB_TFT_SSD1305
./scripts/config --module CONFIG_FB_TFT_SSD1306
./scripts/config --module CONFIG_FB_TFT_SSD1331
./scripts/config --module CONFIG_FB_TFT_SSD1351
./scripts/config --module CONFIG_FB_TFT_ST7735R
./scripts/config --module CONFIG_FB_TFT_ST7789V
./scripts/config --module CONFIG_FB_TFT_TINYLCD
./scripts/config --module CONFIG_FB_TFT_TLS8204
./scripts/config --module CONFIG_FB_TFT_UC1611
./scripts/config --module CONFIG_FB_TFT_UC1701
./scripts/config --module CONFIG_FB_TFT_UPD161704
./scripts/config --module CONFIG_GREYBUS_AUDIO
./scripts/config --module CONFIG_GREYBUS_BOOTROM
./scripts/config --module CONFIG_GREYBUS_FIRMWARE
./scripts/config --module CONFIG_GREYBUS_HID
./scripts/config --module CONFIG_GREYBUS_LOG
./scripts/config --module CONFIG_GREYBUS_LOOPBACK
./scripts/config --module CONFIG_GREYBUS_POWER
./scripts/config --module CONFIG_GREYBUS_RAW
./scripts/config --module CONFIG_GREYBUS_VIBRATOR
./scripts/config --module CONFIG_GREYBUS_BRIDGED_PHY
./scripts/config --module CONFIG_GREYBUS_GPIO
./scripts/config --module CONFIG_GREYBUS_I2C
./scripts/config --module CONFIG_GREYBUS_PWM
./scripts/config --module CONFIG_GREYBUS_SDIO
./scripts/config --module CONFIG_GREYBUS_SPI
./scripts/config --module CONFIG_GREYBUS_UART
./scripts/config --module CONFIG_GREYBUS_USB

./scripts/config --disable CONFIG_CHROME_PLATFORMS

#
# Clock driver for ARM Reference designs
#
./scripts/config --disable CONFIG_CLK_ICST
./scripts/config --disable CONFIG_CLK_SP810
./scripts/config --enable CONFIG_HWSPINLOCK_OMAP

#
# Generic IOMMU Pagetable Support
#
./scripts/config --disable CONFIG_IOMMU_IO_PGTABLE_LPAE

#
# Clock Source drivers
#
./scripts/config --disable CONFIG_ARM_TIMER_SP804

#
# Remoteproc drivers
#
./scripts/config --enable CONFIG_REMOTEPROC_CDEV
./scripts/config --module CONFIG_WKUP_M3_RPROC
./scripts/config --module CONFIG_PRU_REMOTEPROC

# end of Rpmsg drivers
./scripts/config --disable CONFIG_SOUNDWIRE

# end of Qualcomm SoC drivers

./scripts/config --enable CONFIG_SOC_TI
./scripts/config --module CONFIG_AMX3_PM
./scripts/config --module CONFIG_WKUP_M3_IPC
./scripts/config --module CONFIG_TI_PRUSS

#
# DEVFREQ Governors
#
./scripts/config --enable CONFIG_DEVFREQ_GOV_PERFORMANCE
./scripts/config --enable CONFIG_DEVFREQ_GOV_POWERSAVE
./scripts/config --enable CONFIG_DEVFREQ_GOV_USERSPACE
./scripts/config --enable CONFIG_DEVFREQ_GOV_PASSIVE

#
# Extcon Device Drivers
#
./scripts/config --enable CONFIG_EXTCON_GPIO
./scripts/config --enable CONFIG_EXTCON_USB_GPIO
./scripts/config --enable CONFIG_TI_EMIF
./scripts/config --enable CONFIG_TI_EMIF_SRAM
./scripts/config --enable CONFIG_IIO
./scripts/config --module CONFIG_IIO_BUFFER_CB
./scripts/config --module CONFIG_IIO_SW_DEVICE

#
# Accelerometers
#
./scripts/config --module CONFIG_ADXL313
./scripts/config --module CONFIG_ADXL313_I2C
./scripts/config --module CONFIG_ADXL313_SPI
./scripts/config --module CONFIG_ADXL345
./scripts/config --module CONFIG_ADXL345_I2C
./scripts/config --module CONFIG_ADXL345_SPI
./scripts/config --module CONFIG_ADXL355
./scripts/config --module CONFIG_ADXL355_I2C
./scripts/config --module CONFIG_ADXL355_SPI
./scripts/config --module CONFIG_ADXL367
./scripts/config --module CONFIG_ADXL367_SPI
./scripts/config --module CONFIG_ADXL367_I2C
./scripts/config --module CONFIG_ADXL380
./scripts/config --module CONFIG_ADXL380_SPI
./scripts/config --module CONFIG_ADXL380_I2C
./scripts/config --module CONFIG_BMI088_ACCEL
./scripts/config --module CONFIG_BMI088_ACCEL_I2C
./scripts/config --module CONFIG_BMI088_ACCEL_SPI
./scripts/config --module CONFIG_DMARD06
./scripts/config --module CONFIG_FXLS8962AF
./scripts/config --module CONFIG_FXLS8962AF_I2C
./scripts/config --module CONFIG_FXLS8962AF_SPI
./scripts/config --module CONFIG_IIO_KX022A
./scripts/config --module CONFIG_IIO_KX022A_SPI
./scripts/config --module CONFIG_IIO_KX022A_I2C
./scripts/config --module CONFIG_MSA311
./scripts/config --module CONFIG_SCA3300

#
# Analog to digital converters
#
./scripts/config --module CONFIG_AD4000
./scripts/config --module CONFIG_AD4030
./scripts/config --module CONFIG_AD4130
./scripts/config --module CONFIG_AD4695
./scripts/config --module CONFIG_AD4851
./scripts/config --module CONFIG_AD7091R8
./scripts/config --module CONFIG_AD7173
./scripts/config --module CONFIG_AD7191
./scripts/config --module CONFIG_AD7280
./scripts/config --module CONFIG_AD7380
./scripts/config --module CONFIG_AD7625
./scripts/config --module CONFIG_AD7779
./scripts/config --module CONFIG_AD7944
./scripts/config --module CONFIG_ENVELOPE_DETECTOR
./scripts/config --module CONFIG_GEHC_PMC_ADC
./scripts/config --module CONFIG_LTC2309
./scripts/config --module CONFIG_MAX11205
./scripts/config --module CONFIG_MAX11410
./scripts/config --module CONFIG_MAX34408
./scripts/config --module CONFIG_MCP3564
./scripts/config --module CONFIG_PAC1921
./scripts/config --module CONFIG_PAC1934
./scripts/config --module CONFIG_RICHTEK_RTQ6056
./scripts/config --module CONFIG_SD_ADC_MODULATOR
./scripts/config --module CONFIG_TI_ADS1100
./scripts/config --module CONFIG_TI_ADS1119
./scripts/config --module CONFIG_TI_ADS124S08
./scripts/config --module CONFIG_TI_ADS1298
./scripts/config --module CONFIG_TI_ADS131E08
./scripts/config --module CONFIG_TI_ADS7138
./scripts/config --module CONFIG_TI_ADS7924
./scripts/config --module CONFIG_TI_ADS8344
./scripts/config --module CONFIG_TI_ADS8688
./scripts/config --enable CONFIG_TI_AM335X_ADC
./scripts/config --module CONFIG_TI_TLC4541
./scripts/config --module CONFIG_TI_TSC2046

#
# Analog to digital and digital to analog converters
#
./scripts/config --module CONFIG_AD74115
./scripts/config --module CONFIG_AD74413R

#
# Analog Front Ends
#
./scripts/config --module CONFIG_IIO_RESCALE

#
# Amplifiers
#
./scripts/config --module CONFIG_AD8366
./scripts/config --module CONFIG_ADA4250
./scripts/config --module CONFIG_HMC425

#
# Capacitance to digital converters
#
./scripts/config --module CONFIG_AD7150
./scripts/config --module CONFIG_AD7746

#
# Chemical Sensors
#
./scripts/config --module CONFIG_AOSONG_AGS02MA
./scripts/config --module CONFIG_ATLAS_PH_SENSOR
./scripts/config --module CONFIG_ATLAS_EZO_SENSOR
./scripts/config --module CONFIG_BME680
./scripts/config --module CONFIG_BME680_I2C
./scripts/config --module CONFIG_BME680_SPI
./scripts/config --module CONFIG_CCS811
./scripts/config --module CONFIG_ENS160
./scripts/config --module CONFIG_ENS160_I2C
./scripts/config --module CONFIG_ENS160_SPI
./scripts/config --module CONFIG_IAQCORE

./scripts/config --module CONFIG_PMS7003
./scripts/config --module CONFIG_SCD30_CORE
./scripts/config --module CONFIG_SCD30_I2C
./scripts/config --module CONFIG_SCD30_SERIAL
./scripts/config --module CONFIG_SCD4X

./scripts/config --module CONFIG_SENSIRION_SGP30
./scripts/config --module CONFIG_SENSIRION_SGP40
./scripts/config --module CONFIG_SPS30
./scripts/config --module CONFIG_SPS30_I2C
./scripts/config --module CONFIG_SPS30_SERIAL
./scripts/config --module CONFIG_SENSEAIR_SUNRISE_CO2
./scripts/config --module CONFIG_VZ89X

#
# Digital to analog converters
#
./scripts/config --module CONFIG_AD3552R_HS
./scripts/config --module CONFIG_AD3552R_LIB
./scripts/config --module CONFIG_AD3552R
./scripts/config --module CONFIG_AD9739A
./scripts/config --module CONFIG_LTC2688
./scripts/config --module CONFIG_AD5766
./scripts/config --module CONFIG_AD7293
./scripts/config --module CONFIG_AD8460
./scripts/config --module CONFIG_BD79703
./scripts/config --module CONFIG_DPOT_DAC
./scripts/config --module CONFIG_LTC2664
./scripts/config --module CONFIG_MAX5522
./scripts/config --module CONFIG_MAX5821
./scripts/config --module CONFIG_MCP4728
./scripts/config --module CONFIG_MCP4821

#
# Clock Generator/Distribution
#
./scripts/config --module CONFIG_AD9523

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
./scripts/config --module CONFIG_ADF4350
./scripts/config --module CONFIG_ADF4371
./scripts/config --module CONFIG_ADF4377
./scripts/config --module CONFIG_ADMFM2000
./scripts/config --module CONFIG_ADMV1013
./scripts/config --module CONFIG_ADMV4420
./scripts/config --module CONFIG_ADRF6780

#
# Heart Rate Monitors
#
./scripts/config --module CONFIG_AFE4403
./scripts/config --module CONFIG_AFE4404
./scripts/config --module CONFIG_MAX30100
./scripts/config --module CONFIG_MAX30102

#
# Humidity sensors
#
./scripts/config --module CONFIG_AM2315
./scripts/config --module CONFIG_ENS210
./scripts/config --module CONFIG_HDC100X
./scripts/config --module CONFIG_HDC2010
./scripts/config --module CONFIG_HDC3020
./scripts/config --module CONFIG_HID_SENSOR_HUMIDITY
./scripts/config --module CONFIG_HTS221
./scripts/config --module CONFIG_HTS221_I2C
./scripts/config --module CONFIG_HTS221_SPI
./scripts/config --module CONFIG_HTU21
./scripts/config --module CONFIG_SI7005
./scripts/config --module CONFIG_SI7020

#
# Inertial measurement units
#
./scripts/config --module CONFIG_ADIS16400
./scripts/config --module CONFIG_ADIS16550
./scripts/config --module CONFIG_BMI270
./scripts/config --module CONFIG_BMI270_I2C
./scripts/config --module CONFIG_BMI270_SPI
./scripts/config --module CONFIG_BMI323
./scripts/config --module CONFIG_BMI323_I2C
./scripts/config --module CONFIG_BMI323_SPI
./scripts/config --module CONFIG_BOSCH_BNO055
./scripts/config --module CONFIG_BOSCH_BNO055_SERIAL
./scripts/config --module CONFIG_BOSCH_BNO055_I2C
./scripts/config --module CONFIG_SMI240
./scripts/config --module CONFIG_IIO_ST_LSM9DS0
./scripts/config --module CONFIG_IIO_ST_LSM9DS0_I2C
./scripts/config --module CONFIG_IIO_ST_LSM9DS0_SPI

#
# Light sensors
#
./scripts/config --module CONFIG_AL3000A
./scripts/config --module CONFIG_APDS9160
./scripts/config --module CONFIG_APDS9306
./scripts/config --module CONFIG_BH1745
./scripts/config --module CONFIG_CM3605
./scripts/config --module CONFIG_ISL76682
./scripts/config --module CONFIG_ROHM_BU27034
./scripts/config --module CONFIG_LTR390
./scripts/config --module CONFIG_LTRF216A
./scripts/config --module CONFIG_OPT4001
./scripts/config --module CONFIG_OPT4060
./scripts/config --module CONFIG_TSL2591
./scripts/config --module CONFIG_VEML3235
./scripts/config --module CONFIG_VEML6040
./scripts/config --module CONFIG_VEML6075

#
# Magnetometer sensors
#
./scripts/config --module CONFIG_AF8133J
./scripts/config --module CONFIG_AK8974
./scripts/config --module CONFIG_ALS31300
./scripts/config --module CONFIG_SI7210
./scripts/config --module CONFIG_TI_TMAG5273
./scripts/config --module CONFIG_YAMAHA_YAS530

#
# Multiplexers
#
./scripts/config --module CONFIG_IIO_MUX

#
# Triggers - standalone
#
./scripts/config --module CONFIG_IIO_TIGHTLOOP_TRIGGER

#
# Linear and angular position sensors
#
./scripts/config --module CONFIG_HID_SENSOR_CUSTOM_INTEL_HINGE

#
# Digital potentiometers
#
./scripts/config --module CONFIG_AD5110
./scripts/config --module CONFIG_AD5272
./scripts/config --module CONFIG_DS1803
./scripts/config --module CONFIG_MAX5432
./scripts/config --module CONFIG_MAX5481
./scripts/config --module CONFIG_MAX5487
./scripts/config --module CONFIG_MCP4018
./scripts/config --module CONFIG_MCP4131
./scripts/config --module CONFIG_MCP4531
./scripts/config --module CONFIG_MCP41010
./scripts/config --module CONFIG_TPL0102
./scripts/config --module CONFIG_X9250

#
# Digital potentiostats
#
./scripts/config --module CONFIG_LMP91000

#
# Pressure sensors
#
./scripts/config --module CONFIG_ROHM_BM1390
./scripts/config --module CONFIG_HSC030PA
./scripts/config --module CONFIG_HSC030PA_I2C
./scripts/config --module CONFIG_HSC030PA_SPI
./scripts/config --module CONFIG_MPRLS0025PA
./scripts/config --module CONFIG_MPRLS0025PA_I2C
./scripts/config --module CONFIG_MPRLS0025PA_SPI
./scripts/config --module CONFIG_MS5611_I2C
./scripts/config --module CONFIG_MS5611_SPI
./scripts/config --module CONFIG_SDP500

#
# Lightning sensors
#
./scripts/config --module CONFIG_AS3935

#
# Proximity and distance sensors
#
./scripts/config --module CONFIG_HX9023S
./scripts/config --module CONFIG_IRSD200
./scripts/config --module CONFIG_SX9324
./scripts/config --module CONFIG_SX9360
./scripts/config --module CONFIG_SX9500
./scripts/config --module CONFIG_AW96103

#
# Resolver to digital converters
#
./scripts/config --module CONFIG_AD2S90
./scripts/config --module CONFIG_AD2S1200
./scripts/config --module CONFIG_AD2S1210

#
# Temperature sensors
#
./scripts/config --module CONFIG_MLX90635
./scripts/config --module CONFIG_TMP117
./scripts/config --module CONFIG_MAX30208
./scripts/config --module CONFIG_MAX31865
./scripts/config --module CONFIG_MCP9600

# end of Temperature sensors
./scripts/config --module CONFIG_PWM_GPIO
./scripts/config --enable CONFIG_PWM_OMAP_DMTIMER
./scripts/config --enable CONFIG_PWM_PCA9685
./scripts/config --enable CONFIG_PWM_TIECAP
./scripts/config --enable CONFIG_PWM_TIEHRPWM

# end of IRQ chip support
./scripts/config --enable CONFIG_RESET_TI_SYSCON

#
# PHY Subsystem
#
./scripts/config --disable CONFIG_OMAP_CONTROL_PHY
./scripts/config --disable CONFIG_OMAP_USB2
./scripts/config --disable CONFIG_TI_PIPE3

#
# Layout Types
#
./scripts/config --enable CONFIG_NVMEM_LAYOUT_U_BOOT_ENV
./scripts/config --enable CONFIG_NVMEM_U_BOOT_ENV

#
# HW tracing support
#
./scripts/config --disable CONFIG_STM

# end of HW tracing support
./scripts/config --disable CONFIG_FSI

#
# Multiplexer drivers
#
./scripts/config --module CONFIG_MUX_ADG792A
./scripts/config --module CONFIG_MUX_ADGS1408
./scripts/config --module CONFIG_MUX_GPIO

./scripts/config --disable CONFIG_SLIMBUS
./scripts/config --disable CONFIG_INTERCONNECT
./scripts/config --module CONFIG_COUNTER
./scripts/config --module CONFIG_INTERRUPT_CNT
./scripts/config --module CONFIG_TI_ECAP_CAPTURE
./scripts/config --module CONFIG_TI_EQEP
./scripts/config --enable CONFIG_HTE

#
# File systems
#
./scripts/config --enable CONFIG_VALIDATE_FS_PARSER
./scripts/config --enable CONFIG_EXT4_FS
./scripts/config --enable CONFIG_XFS_FS
./scripts/config --disable CONFIG_OCFS2_FS
./scripts/config --enable CONFIG_BTRFS_FS
./scripts/config --disable CONFIG_NILFS2_FS
./scripts/config --enable CONFIG_F2FS_FS
./scripts/config --disable CONFIG_BCACHEFS_FS
./scripts/config --enable CONFIG_AUTOFS_FS
./scripts/config --enable CONFIG_OVERLAY_FS

#
# DOS/FAT/EXFAT/NT Filesystems
#
./scripts/config --enable CONFIG_FAT_FS
./scripts/config --enable CONFIG_MSDOS_FS
./scripts/config --enable CONFIG_VFAT_FS

#
# Pseudo filesystems
#
./scripts/config --enable CONFIG_CONFIGFS_FS
./scripts/config --disable CONFIG_ORANGEFS_FS
./scripts/config --disable CONFIG_ADFS_FS
./scripts/config --disable CONFIG_AFFS_FS
./scripts/config --disable CONFIG_HFS_FS
./scripts/config --disable CONFIG_HFSPLUS_FS
./scripts/config --disable CONFIG_BEFS_FS
./scripts/config --disable CONFIG_BFS_FS
./scripts/config --disable CONFIG_EFS_FS
./scripts/config --enable CONFIG_UBIFS_FS
./scripts/config --disable CONFIG_VXFS_FS
./scripts/config --disable CONFIG_MINIX_FS
./scripts/config --disable CONFIG_OMFS_FS
./scripts/config --disable CONFIG_HPFS_FS
./scripts/config --disable CONFIG_QNX4FS_FS
./scripts/config --disable CONFIG_QNX6FS_FS
./scripts/config --disable CONFIG_UFS_FS
./scripts/config --disable CONFIG_EROFS_FS
./scripts/config --enable CONFIG_NFS_FS
./scripts/config --enable CONFIG_NFS_V2
./scripts/config --enable CONFIG_NFS_V3
./scripts/config --enable CONFIG_NFS_V4
./scripts/config --enable CONFIG_ROOT_NFS

./scripts/config --enable CONFIG_NLS_CODEPAGE_437
./scripts/config --enable CONFIG_NLS_ASCII

#
# Security options
#
./scripts/config --disable CONFIG_PERSISTENT_KEYRINGS
./scripts/config --disable CONFIG_SECURITY_DMESG_RESTRICT
./scripts/config --disable CONFIG_SECURITY_LOCKDOWN_LSM
./scripts/config --disable CONFIG_SECURITY_IPE
./scripts/config --disable CONFIG_IMA_BLACKLIST_KEYRING
./scripts/config --disable CONFIG_IMA_LOAD_X509

#
# Certificates for signature checking
#
./scripts/config --disable CONFIG_SECONDARY_TRUSTED_KEYRING
./scripts/config --disable CONFIG_SYSTEM_BLACKLIST_KEYRING

# end of Accelerated Cryptographic Algorithms for CPU (arm)
./scripts/config --enable CONFIG_CRYPTO_DEV_OMAP
./scripts/config --enable CONFIG_CRYPTO_DEV_OMAP_SHAM
./scripts/config --enable CONFIG_CRYPTO_DEV_OMAP_AES
./scripts/config --enable CONFIG_CRYPTO_DEV_OMAP_DES
./scripts/config --disable CONFIG_CRYPTO_DEV_AMLOGIC_GXL

#
# Library routines
#
./scripts/config --disable CONFIG_RAID6_PQ_BENCHMARK

#
# Default contiguous memory area size:
#
./scripts/config --set-val CONFIG_CMA_SIZE_MBYTES 48

#
# Compile-time checks and compiler options
#
./scripts/config --disable CONFIG_DEBUG_INFO
./scripts/config --enable CONFIG_DEBUG_INFO_NONE
./scripts/config --disable CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
./scripts/config --enable CONFIG_HEADERS_INSTALL
./scripts/config --enable CONFIG_DEBUG_SECTION_MISMATCH

# end of RCU Debugging
./scripts/config --disable CONFIG_STRICT_DEVMEM

#
# arm Debugging
#
./scripts/config --disable CONFIG_CORESIGHT

#
# Kernel Testing and Coverage
#
./scripts/config --disable CONFIG_RUNTIME_TESTING_MENU

#
# Memory Debugging
#
./scripts/config --enable CONFIG_PAGE_OWNER


# end of Memory Debugging
./scripts/config --enable CONFIG_DEBUG_SHIRQ

#
# Debug Oops, Lockups and Hangs
#
./scripts/config --enable CONFIG_WQ_CPU_INTENSIVE_REPORT

#
# RCU Debugging
#
./scripts/config --enable CONFIG_RCU_CPU_STALL_CPUTIME

# end of RCU Debugging
./scripts/config --enable CONFIG_BOOTTIME_TRACING
./scripts/config --enable CONFIG_FUNCTION_PROFILER
./scripts/config --enable CONFIG_STACK_TRACER
./scripts/config --enable CONFIG_SCHED_TRACER
./scripts/config --enable CONFIG_HWLAT_TRACER
./scripts/config --enable CONFIG_TIMERLAT_TRACER

#
# Kernel Testing and Coverage
#
./scripts/config --enable CONFIG_FUNCTION_ERROR_INJECTION
./scripts/config --enable CONFIG_MEMTEST

###BUGS...

#debian Trixie has fubared lz4/lz4c, back to xz for stabilty...
#  LZ4     arch/arm/boot/compressed/piggy_data
#Error : stdout won't be used ! Do you want multiple input files (-m) ?
#make[3]: *** [arch/arm/boot/compressed/Makefile:156: arch/arm/boot/compressed/piggy_data] Error 1

./scripts/config --disable CONFIG_KERNEL_LZO
./scripts/config --disable CONFIG_KERNEL_LZ4
./scripts/config --enable CONFIG_KERNEL_XZ

#Cool for debugging, little noisy on production...
./scripts/config --disable CONFIG_UBSAN

cd ${DIR}/
