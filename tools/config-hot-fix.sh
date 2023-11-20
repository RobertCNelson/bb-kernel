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

#Docker.io:
config="CONFIG_CGROUP_HUGETLB" ; config_enable
config="CONFIG_RT_GROUP_SCHED" ; config_enable

#PHY: CONFIG_DP83867_PHY
config="CONFIG_DP83867_PHY" ; config_enable

#PRU: CONFIG_PRU_REMOTEPROC
config="CONFIG_REMOTEPROC" ; config_enable
config="CONFIG_REMOTEPROC_CDEV" ; config_enable
config="CONFIG_WKUP_M3_RPROC" ; config_enable
config="CONFIG_PRU_REMOTEPROC" ; config_module

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
config="CONFIG_KERNEL_LZO" ; config_disable
config="CONFIG_KERNEL_LZ4" ; config_enable
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

cd ${DIR}/
