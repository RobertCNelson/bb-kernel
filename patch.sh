#!/bin/bash -e

# SPDX-FileCopyrightText: 2009 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

# Split out, so build_kernel.sh and build_deb.sh can share..

shopt -s nullglob

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi
git_bin=$(which git)
#git hard requirements:
#git: --no-edit

git="${git_bin} am"
#git_patchset=""
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="${git_bin} apply"
fi

echo "Starting patch.sh"

git_add () {
	${git_bin} add .
	${git_bin} commit -a -m 'testing patchset'
}

start_cleanup () {
	git="${git_bin} am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		if [ "x${wdir}" = "x" ] ; then
			${git_bin} format-patch -${number} -o ${DIR}/patches/
		else
			if [ ! -d ${DIR}/patches/${wdir}/ ] ; then
				mkdir -p ${DIR}/patches/${wdir}/
			fi
			${git_bin} format-patch -${number} -o ${DIR}/patches/${wdir}/
			unset wdir
		fi
	fi
	exit 2
}

dir () {
	wdir="$1"
	if [ -d "${DIR}/patches/$wdir" ]; then
		echo "dir: $wdir"

		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		number=
		for p in "${DIR}/patches/$wdir/"*.patch; do
			${git} "$p"
			number=$(( $number + 1 ))
		done

		if [ "x${regenerate}" = "xenable" ] ; then
			cleanup
		fi
	fi
	unset wdir
}

cherrypick () {
	if [ ! -d ../patches/${cherrypick_dir} ] ; then
		mkdir -p ../patches/${cherrypick_dir}
	fi
	${git_bin} format-patch -1 ${SHA} --start-number ${num} -o ../patches/${cherrypick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag=""
	echo "pulling: ${git_tag}"
	${git_bin} pull --no-edit ${git_patchset} ${git_tag}
	${git_bin} describe
}

wpanusb () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./wpanusb ] ; then
			rm -rf ./wpanusb || true
		fi

		${git_bin} clone https://openbeagle.org/beagleconnect/linux/wpanusb.git --depth=1
		cd ./wpanusb
			wpanusb_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cp -v ../wpanusb/wpanusb.h drivers/net/ieee802154/
		cp -v ../wpanusb/wpanusb.c drivers/net/ieee802154/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: wpanusb: https://git.beagleboard.org/beagleconnect/linux/wpanusb' -m "https://openbeagle.org/beagleconnect/linux/wpanusb/-/commit/${wpanusb_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/wpanusb/
		echo "WPANUSB: https://openbeagle.org/beagleconnect/linux/wpanusb/-/commit/${wpanusb_hash}" > ../patches/external/git/WPANUSB

		rm -rf ../wpanusb/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/external/wpanusb/0001-merge-wpanusb-https-git.beagleboard.org-beagleconnec.patch"

		wdir="external/wpanusb"
		number=1
		cleanup
	fi
	dir 'external/wpanusb'
}

bcfserial () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./bcfserial ] ; then
			rm -rf ./bcfserial || true
		fi

		${git_bin} clone https://openbeagle.org/beagleconnect/linux/bcfserial.git --depth=1
		cd ./bcfserial
			bcfserial_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cp -v ../bcfserial/bcfserial.c drivers/net/ieee802154/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: bcfserial: https://git.beagleboard.org/beagleconnect/linux/bcfserial.git' -m "https://openbeagle.org/beagleconnect/linux/bcfserial/-/commit/${bcfserial_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/bcfserial/
		echo "BCFSERIAL: https://openbeagle.org/beagleconnect/linux/bcfserial/-/commit/${bcfserial_hash}" > ../patches/external/git/BCFSERIAL

		rm -rf ../bcfserial/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/external/bcfserial/0001-merge-bcfserial-https-git.beagleboard.org-beagleconn.patch"

		wdir="external/bcfserial"
		number=1
		cleanup
	fi
	dir 'external/bcfserial'
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	#rt_enable="enable"
	if [ "x${rt_enable}" = "xenable" ] ; then
		rt_patch="${KERNEL_REL}${kernel_rt}"

		#${git_bin} revert --no-edit xyz

		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			wget -c https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/older/patch-${rt_patch}.patch.xz
			xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
			rm -f patch-${rt_patch}.patch.xz
			rm -f localversion-rt
			${git_bin} add .
			${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -m "patch-${rt_patch}.patch.xz" -s
			${git_bin} format-patch -1 -o ../patches/external/rt/
			#echo "RT: patch-${rt_patch}.patch.xz" > ../patches/external/git/RT

			exit 2
		fi
		dir 'external/rt'
	fi
}

wireless_regdb () {
	#https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./src ] ; then
			rm -rf ./src || true
		fi

		wget -c https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/snapshot/wireless-regdb-master-${WIRELESS_REGDB}.tar.gz
		mkdir ./src/
		tar xf wireless-regdb-master-${WIRELESS_REGDB}.tar.gz -C ./src/
		sync
		rm -rf wireless-regdb-master-${WIRELESS_REGDB}.tar.gz

		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../src/wireless-regdb-master-${WIRELESS_REGDB}/regulatory.db ./firmware/
		cp -v ../src/wireless-regdb-master-${WIRELESS_REGDB}/regulatory.db.p7s ./firmware/
		${git_bin} add -f ./firmware/regulatory.*

		${git_bin} commit -a -m 'Add wireless-regdb regulatory database file' -m "https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tag/?h=master-${WIRELESS_REGDB}" -s

		${git_bin} format-patch -1 -o ../patches/external/wireless_regdb/
		echo "WIRELESS_REGDB: https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tag/?h=master-${WIRELESS_REGDB}" > ../patches/external/git/WIRELESS_REGDB

		rm -rf ../src/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/external/wireless_regdb/0001-Add-wireless-regdb-regulatory-database-file.patch"

		wdir="external/wireless_regdb"
		number=1
		cleanup
	fi
	dir 'external/wireless_regdb'
}

cleanup_dts_builds () {
	rm -rf arch/arm/boot/dts/modules.order || true
	rm -rf arch/arm/boot/dts/.*cmd || true
	rm -rf arch/arm/boot/dts/.*tmp || true
	rm -rf arch/arm/boot/dts/*dtb || true
	rm -rf arch/arm/boot/dts/*dtbo || true
	rm -rf arch/arm64/boot/dts/ti/modules.order || true
	rm -rf arch/arm64/boot/dts/ti/.*cmd || true
	rm -rf arch/arm64/boot/dts/ti/.*tmp || true
	rm -rf arch/arm64/boot/dts/ti/*dtb || true
	rm -rf arch/arm64/boot/dts/ti/*dtbo || true
}

arm_makefile_patch_of_overlays () {
	cat arch/arm/boot/dts/Makefile  | grep -v '#'> arch/arm/boot/dts/Makefile.bak
	echo "# SPDX-License-Identifier: GPL-2.0" > arch/arm/boot/dts/Makefile
	echo "" >> arch/arm/boot/dts/Makefile
	echo "ifeq (\$(CONFIG_OF_OVERLAY),y)" >> arch/arm/boot/dts/Makefile
	echo "DTC_FLAGS += -@" >> arch/arm/boot/dts/Makefile
	echo "endif" >> arch/arm/boot/dts/Makefile
	echo "" >> arch/arm/boot/dts/Makefile
	cat arch/arm/boot/dts/Makefile.bak >> arch/arm/boot/dts/Makefile
	rm -rf arch/arm/boot/dts/Makefile.bak
}

arm_dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

arm_dtbo_makefile_append () {
	if [ -f ../${work_dir}/src/arm/overlays/${device}.dtso ] ; then
		sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device'.dtbo \\:g' arch/arm/boot/dts/Makefile
		cp -v ../${work_dir}/src/arm/overlays/${device}.dtso arch/arm/boot/dts/${device}.dtso
	else
		echo "Missing [${device}]"
	fi
}

k3_dtb_makefile_append () {
	echo "dtb-\$(CONFIG_ARCH_K3) += $device" >> arch/arm64/boot/dts/ti/Makefile
}

regenerate_arm_dtbo_list () {
	cd ../${work_dir}/src/arm/overlays/
	echo "-----------------------------"
	for f in *.dtso; do echo "device=\"${f%.dtso}\" ; arm_dtbo_makefile_append"; done
	echo "-----------------------------"
	cd -
	exit 2
}

beagleboard_dtbs () {
	branch="v6.1.x"
	https_repo="https://github.com/beagleboard/BeagleBoard-DeviceTrees.git"
	work_dir="BeagleBoard-DeviceTrees"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./${work_dir} ] ; then
			rm -rf ./${work_dir} || true
		fi

		${git_bin} clone -b ${branch} ${https_repo} --depth=1
		cd ./${work_dir}
			git_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cleanup_dts_builds
		rm -rf arch/arm/boot/dts/overlays/ || true
		rm -rf arch/arm64/boot/dts/ti/overlays/ || true
		arm_makefile_patch_of_overlays

		cp -v ../${work_dir}/src/arm/ti/omap/*.dts arch/arm/boot/dts/
		cp -v ../${work_dir}/src/arm/ti/omap/*.dtsi arch/arm/boot/dts/
		cp -v ../${work_dir}/src/arm64/ti/*.dts arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.dtsi arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.h arch/arm64/boot/dts/ti/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		#regenerate_arm_dtbo_list

		device="AM3359-PWM012" ; arm_dtbo_makefile_append
		device="AM335X-PRU-P9-25" ; arm_dtbo_makefile_append
		device="AM335X-PRU-UIO-00A0" ; arm_dtbo_makefile_append
		device="AM57XX-PRU-UIO-00A0" ; arm_dtbo_makefile_append
		device="BB-ADC-00A0" ; arm_dtbo_makefile_append
		device="BB-BBBW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGG-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BONE-4D4C-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-4D5R-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-eMMC1-01-00A0" ; arm_dtbo_makefile_append
		device="BB-BONE-LCD4-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-NH7C-01-A0" ; arm_dtbo_makefile_append
		device="BB-CAN0-00A0" ; arm_dtbo_makefile_append
		device="BB-CAN1-00A0" ; arm_dtbo_makefile_append
		device="BB-CAPE-DISP-CT4-00A0" ; arm_dtbo_makefile_append
		device="BB-EHRPWM0-P9_29-P9_31" ; arm_dtbo_makefile_append
		device="BB-EHRPWM1-P9_14-P9_16" ; arm_dtbo_makefile_append
		device="BB-EHRPWM2-P8_13-P8_19" ; arm_dtbo_makefile_append
		device="BB-EQEP0" ; arm_dtbo_makefile_append
		device="BB-EQEP1" ; arm_dtbo_makefile_append
		device="BB-EQEP2B" ; arm_dtbo_makefile_append
		device="BB-EQEP2" ; arm_dtbo_makefile_append
		device="BB-GREEN-HDMI-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-IT66121-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-IT66122-00A0" ; arm_dtbo_makefile_append
		device="BB-HDMI-TDA998x-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-ADS1015-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-FAST-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-MCP7940X-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C1-RTC-DS3231" ; arm_dtbo_makefile_append
		device="BB-I2C1-RTC-PCF8563" ; arm_dtbo_makefile_append
		device="BB-I2C2-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-BME680" ; arm_dtbo_makefile_append
		device="BB-I2C2-FAST-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-MCP7940X-00A0" ; arm_dtbo_makefile_append
		device="BB-I2C2-MPU6050" ; arm_dtbo_makefile_append
		device="BB-I2C2-RTC-DS3231" ; arm_dtbo_makefile_append
		device="BB-LCD-ADAFRUIT-24-SPI1-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-IT66121-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-IT66122-00A0" ; arm_dtbo_makefile_append
		device="BB-NHDMI-TDA998x-00A0" ; arm_dtbo_makefile_append
		device="BBORG_COMMS-00A2" ; arm_dtbo_makefile_append
		device="BBORG_FAN-A000" ; arm_dtbo_makefile_append
		device="BBORG_RELAY-00A2" ; arm_dtbo_makefile_append
		device="BB-SPIDEV0-00A0" ; arm_dtbo_makefile_append
		device="BB-SPIDEV1-00A0-CS1" ; arm_dtbo_makefile_append
		device="BB-SPIDEV1-00A0" ; arm_dtbo_makefile_append
		device="BB-UART1-00A0" ; arm_dtbo_makefile_append
		device="BB-UART2-00A0" ; arm_dtbo_makefile_append
		device="BB-UART4-00A0" ; arm_dtbo_makefile_append
		device="BB-UART5-00A0" ; arm_dtbo_makefile_append
		device="BB-W1-P9.12-00A0" ; arm_dtbo_makefile_append
		device="BONE-ADC" ; arm_dtbo_makefile_append
		device="BONE-LED-P8-37" ; arm_dtbo_makefile_append
		device="BONE-LED-P9-19" ; arm_dtbo_makefile_append
		device="BONE-LED-P9-42" ; arm_dtbo_makefile_append
		device="M-BB-BBG-00A0" ; arm_dtbo_makefile_append
		device="M-BB-BBGG-00A0" ; arm_dtbo_makefile_append
		device="PB-MIKROBUS-0" ; arm_dtbo_makefile_append
		device="PB-MIKROBUS-1" ; arm_dtbo_makefile_append

		#am335x Devices
		device="am335x-boneblack-uboot.dtb" ; arm_dtb_makefile_append
		device="am335x-boneblack-revd.dtb" ; arm_dtb_makefile_append
		device="am335x-bonegreen-eco.dtb" ; arm_dtb_makefile_append

		#device="am335x-sancloud-bbe-uboot.dtb" ; arm_dtb_makefile_append
		#device="am335x-sancloud-bbe-lite-uboot.dtb" ; arm_dtb_makefile_append
		#device="am335x-sancloud-bbe-extended-wifi-uboot.dtb" ; arm_dtb_makefile_append

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f arch/arm64/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "https://github.com/beagleboard/BeagleBoard-DeviceTrees/tree/${branch}" -m "https://github.com/beagleboard/BeagleBoard-DeviceTrees/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/bbb.io/
		echo "BBDTBS: https://github.com/beagleboard/BeagleBoard-DeviceTrees/commit/${git_hash}" > ../patches/external/git/BBDTBS

		rm -rf ../${work_dir}/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/external/bbb.io/0001-Add-BeagleBoard.org-Device-Tree-Changes.patch"

		wdir="external/bbb.io"
		number=1
		cleanup
	fi
	dir 'external/bbb.io'
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
wpanusb
bcfserial
rt
wireless_regdb
beagleboard_dtbs
#local_patch

dtc_overlays () {
	dir 'dtc_overlays'
}

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git master
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git master --tags
	${git_bin} pull --no-edit https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		echo "${git_bin} checkout ${backport_tag} -f"
		${git_bin} checkout ${backport_tag} -f
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
	exit 2
}

patch_backports () {
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

pre_rpibackports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-rpi/
	${git_bin} fetch --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		echo "${git_bin} checkout ${backport_tag} -f"
		${git_bin} checkout ${backport_tag} -f
	fi
	cd -
}

post_rpibackports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-rpi/
		${git_bin} checkout master -f
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
	exit 2
}

backports () {
	subsystem="uio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		unset backport_tag

		cp -v ../patches/drivers/ti/uio/uio_pruss.c ./drivers/uio/

		post_backports
	else
		patch_backports
		dir 'drivers/ti/uio'
	fi

	backport_tag="v6.8.12"

	subsystem="it66121"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/gpu/drm/bridge/ite-it66121.c ./drivers/gpu/drm/bridge/

		post_backports
	else
		patch_backports

		#i2c (v6.1.x)
		${git} "${DIR}/patches/mainline/i2c/0001-i2c-core-Introduce-i2c_client_get_device_id-helper-f.patch"

		#v6.10.x+
		${git} "${DIR}/patches/mainline/ite-it66121/0018-drm-bridge-ite66121-Register-HPD-interrupt-handler-o.patch"
	fi

	backport_tag="rpi-6.1.y"

	subsystem="edt-ft5x06"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_rpibackports

		cp -v ~/linux-rpi/drivers/input/touchscreen/edt-ft5x06.c ./drivers/input/touchscreen/

		post_rpibackports
	else
		patch_backports
	fi
}

drivers () {
	dir 'branding/boris'

	dir 'drivers/ar1021_i2c'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/tsc'
	dir 'drivers/fb_ssd1306'

	dir 'drivers/it66121_drm_connector'
	dir 'drivers/it66121_kernel_specific_fixes'
	dir 'drivers/it66122'

	dir 'drivers/wkup_m3_ipc'
	dir 'external/ti-amx3-cm3-pm-firmware'

#	dir 'drivers/ti-cc33xx-1.0.2.10'
#	dir 'drivers/cc33xx-fixes'
}

###
dtc_overlays
backports
drivers

packaging () {
	echo "Update: package scripts"
	${git} "${DIR}/patches/backports/bindeb-pkg/0002-builddeb-Install-our-dtbs-under-boot-dtbs-version.patch"
}

packaging
echo "patch.sh ran successfully"
#
