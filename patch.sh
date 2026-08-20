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

mainline_patches () {
	#exit 2
	dir 'mainline/pocketbeagle2'
	dir 'mainline/greenecho'
	#exit 2
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

omap_makefile_patch_of_overlays () {
	cat arch/arm/boot/dts/ti/omap/Makefile  | grep -v '#'> arch/arm/boot/dts/ti/omap/Makefile.bak
	echo "# SPDX-License-Identifier: GPL-2.0" > arch/arm/boot/dts/ti/omap/Makefile
	echo "" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "ifeq (\$(CONFIG_OF_OVERLAY),y)" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "DTC_FLAGS += -@" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "endif" >> arch/arm/boot/dts/ti/omap/Makefile
	echo "" >> arch/arm/boot/dts/ti/omap/Makefile
	cat arch/arm/boot/dts/ti/omap/Makefile.bak >> arch/arm/boot/dts/ti/omap/Makefile
	rm -rf arch/arm/boot/dts/ti/omap/Makefile.bak
}

arm_dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/ti/omap/Makefile
}

arm_dtbo_makefile_append () {
	if [ -f ../${work_dir}/src/arm/overlays/${device}.dtso ] ; then
		sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device'.dtbo \\:g' arch/arm/boot/dts/ti/omap/Makefile
		cp -v ../${work_dir}/src/arm/overlays/${device}.dtso arch/arm/boot/dts/ti/omap/${device}.dtso
	else
		echo "Missing [${device}]"
	fi
}

k3_dtb_makefile_append () {
	echo "dtb-\$(CONFIG_ARCH_K3) += $device" >> arch/arm64/boot/dts/ti/Makefile
}

k3_dtbo_makefile_append () {
	if [ -f ../${work_dir}/src/arm64/overlays/${device}.dtso ] ; then
		echo "dtb-\$(CONFIG_ARCH_K3) += $device.dtbo" >> arch/arm64/boot/dts/ti/Makefile
		cp -v ../${work_dir}/src/arm64/overlays/${device}.dtso arch/arm64/boot/dts/ti/${device}.dtso
		sed -i -e 's:ti/k3-:k3-:g' arch/arm64/boot/dts/ti/${device}.dtso
	else
		echo "Missing [${device}]"
	fi
}

k3_makefile_patch_cleanup_overlays () {
	cat arch/arm64/boot/dts/ti/Makefile | grep -v 'DTC_FLAGS_k3' | grep -v '# Enable' > arch/arm64/boot/dts/ti/Makefile.bak
	cat arch/arm64/boot/dts/ti/Makefile | grep 'DTC_FLAGS_k3' > arch/arm64/boot/dts/ti/Makefile.dtc
	rm arch/arm64/boot/dts/ti/Makefile
	mv arch/arm64/boot/dts/ti/Makefile.bak arch/arm64/boot/dts/ti/Makefile
	echo "" >> arch/arm64/boot/dts/ti/Makefile
	echo "# Enable support for device-tree overlays" >> arch/arm64/boot/dts/ti/Makefile
	cat arch/arm64/boot/dts/ti/Makefile.dtc >> arch/arm64/boot/dts/ti/Makefile
	rm arch/arm64/boot/dts/ti/Makefile.dtc
	echo "DTC_FLAGS_k3-am62-pocketbeagle2 += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-am6232-pocketbeagle2 += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-am67a-beagley-ai += -@" >> arch/arm64/boot/dts/ti/Makefile
	echo "DTC_FLAGS_k3-j721e-beagleboneai64 += -@" >> arch/arm64/boot/dts/ti/Makefile
}

regenerate_arm_dtbo_list () {
	cd ../${work_dir}/src/arm/overlays/
	echo "-----------------------------"
	for f in *.dtso; do echo "device=\"${f%.dtso}\" ; arm_dtbo_makefile_append"; done
	echo "-----------------------------"
	cd -
	exit 2
}

regenerate_arm64_dtbo_list () {
	cd ../${work_dir}/src/arm64/overlays/
	echo "-----------------------------"
	for f in *.dtso; do echo "device=\"${f%.dtso}\" ; k3_dtbo_makefile_append"; done
	echo "-----------------------------"
	cd -
	exit 2
}

beagleboard_dtbs () {
	branch="v6.12.x"
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
		rm -rf arch/arm/boot/dts/ti/omap/overlays/ || true
		rm -rf arch/arm64/boot/dts/ti/overlays/ || true
		omap_makefile_patch_of_overlays

		cp -v ../${work_dir}/src/arm/ti/omap/*.dts arch/arm/boot/dts/ti/omap/
		cp -v ../${work_dir}/src/arm/ti/omap/*.dtsi arch/arm/boot/dts/ti/omap/
		cp -v ../${work_dir}/src/arm64/ti/*.dts arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.dtsi arch/arm64/boot/dts/ti/
		cp -v ../${work_dir}/src/arm64/ti/*.h arch/arm64/boot/dts/ti/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/
		if [ -f ./include/dt-bindings/board/am335x-bbw-bbb-base.h ] ; then
			rm -rf ./include/dt-bindings/board/am335x-bbw-bbb-base.h || true
		fi

		#regenerate_arm_dtbo_list

		device="AM3359-PWM012" ; arm_dtbo_makefile_append
		device="AM335X-PRU-UIO-00A0" ; arm_dtbo_makefile_append
		device="BB-ADC-00A0" ; arm_dtbo_makefile_append
		device="BB-BBBW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGG-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BONE-4D4C-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-4D5R-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-eMMC1-01-00A0" ; arm_dtbo_makefile_append
		device="BB-BONE-LCD4-01-00A1" ; arm_dtbo_makefile_append
		device="BB-BONE-LCD7-01-00A3" ; arm_dtbo_makefile_append
		device="BB-CAN0-00A0" ; arm_dtbo_makefile_append
		device="BB-CAN1-00A0" ; arm_dtbo_makefile_append
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

		#am335x Devices
		device="am335x-boneblack-uboot.dtb" ; arm_dtb_makefile_append
		device="am335x-boneblack-revd.dtb" ; arm_dtb_makefile_append

		#regenerate_arm64_dtbo_list

		device="k3-am6232-pocketbeagle2-gamepup-a4" ; k3_dtbo_makefile_append
		device="k3-am6232-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append
		device="k3-am625-beagleplay-bcfserial-no-firmware" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-ardupilot-cape" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-led-all" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-leds-off" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-mspm0swd" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-pru0-out" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-spi2-eth-wiz-click" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-400000" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ads1115" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-rtc-rv3028" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ssd1306" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-mikroe-eth" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-mikroe-microsd" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pps-gpio18" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap0-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap1-gpio16" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap1-gpio21" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap2-gpio17" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-ecap2-gpio18" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio15-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5-gpio12" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm0-gpio5-gpio14" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio21-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6-gpio13" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-pwm-epwm1-gpio6-gpio20" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spi0-1cs" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spi0-2cs" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-spidev0" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-uart-ttyama0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-BBORG_MOTOR" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-ecap2" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-eqep0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-eqep1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-io-pins" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm4-p9_25" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-rs485-uart8" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi2-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi3-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0-cs1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs1-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi7-cs0" ; k3_dtbo_makefile_append

		#K3 Devices
		device="k3-am6232-pocketbeagle2.dtb" ; k3_dtb_makefile_append
		device="k3-am625-sancloud-bbe-2.dtb" ; k3_dtb_makefile_append

		k3_makefile_patch_cleanup_overlays

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
mainline_patches
rt
wireless_regdb
beagleboard_dtbs
#local_patch

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
	${git_bin} commit -a -m "backports ${subsystem} from linux" -m "Reference: ${backport_tag}" -s
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
	${git_bin} commit -a -m "backports ${subsystem} from raspberrypi-linux" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
	exit 2
}

backports () {
	backport_tag="v6.16.12"

	subsystem="tps65219"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/input/misc/tps65219-pwrbutton.c ./drivers/input/misc/
		cp -v ~/linux-src/drivers/mfd/tps65219.c ./drivers/mfd/
		cp -v ~/linux-src/drivers/gpio/gpio-tps65219.c ./drivers/gpio/
		cp -v ~/linux-src/drivers/regulator/tps65219-regulator.c ./drivers/regulator/
		cp -v ~/linux-src/Documentation/devicetree/bindings/regulator/ti,tps65219.yaml ./Documentation/devicetree/bindings/regulator/
		cp -v ~/linux-src/include/linux/mfd/tps65219.h ./include/linux/mfd/

		post_backports
	else
		patch_backports
	fi

	backport_tag="v6.13.12"

	subsystem="it66121"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/gpu/drm/bridge/ite-it66121.c ./drivers/gpu/drm/bridge/

		post_backports
	else
		patch_backports

		${git} "${DIR}/patches/mainline/ite-it66121/0022-drm-Use-of_property_present-for-non-boolean-properti.patch"
	fi

	backport_tag="rpi-6.12.y"

	subsystem="rpi-backports"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_rpibackports

		cp -v ~/linux-rpi/drivers/input/touchscreen/edt-ft5x06.c ./drivers/input/touchscreen/
		cp -v ~/linux-rpi/drivers/regulator/rpi-panel-v2-regulator.c ./drivers/regulator/

		post_rpibackports
	else
		dir 'backports/rpi-backports'
	fi

	#dir 'drivers/ti/uio_revert'

	backport_tag="v6.6.114"

	subsystem="uio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/uio/uio_pruss.c ./drivers/uio/

		post_backports
	#else
		patch_backports

		dir 'drivers/ti/uio'
	fi
}

cc33xx_drivers () {
	echo "dir: drivers/cc33xx/v5_20241107"
	#b4 am https://lore.kernel.org/linux-wireless/20241107125209.1736277-1-michael.nemanov@ti.com/
	${git} "${DIR}/patches/drivers/cc33xx/v5_20241107/v5_20241107_michael_nemanov_wifi_cc33xx_add_driver_for_new_ti_cc33xx_wireless_device_family.mbx"

	#exit 2
	#start_cleanup
	dir 'drivers/cc33xx/1.0.2.10'
}

drivers () {
	dir 'branding/boris'

	dir 'drivers/tilcdc-4.12.x/'
	dir 'drivers/tilcdc/'

	dir 'drivers/it66121_drm_connector'
	dir 'drivers/it66122'

	dir 'drivers/wkup_m3_ipc'
	dir 'external/ti-amx3-cm3-pm-firmware'
}

###
backports
drivers
#cc33xx_drivers

packaging () {
	echo "Update: package scripts"
	${git} "${DIR}/patches/backports/bindeb-pkg/0002-builddeb-Install-our-dtbs-under-boot-dtbs-version.patch"
}

packaging
echo "patch.sh ran successfully"
#
