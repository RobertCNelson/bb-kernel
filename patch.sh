#!/bin/bash -e
#
# Copyright (c) 2009-2025 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
	#https://kernel.googlesource.com/pub/scm/linux/kernel/git/wens/wireless-regdb.git
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./src ] ; then
			rm -rf ./src || true
		fi

		${git_bin} clone https://kernel.googlesource.com/pub/scm/linux/kernel/git/wens/wireless-regdb.git --depth=1 ./src/
		cd ./src
			wireless_regdb_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../src/regulatory.db ./firmware/
		cp -v ../src/regulatory.db.p7s ./firmware/
		${git_bin} add -f ./firmware/regulatory.*
		${git_bin} commit -a -m 'Add wireless-regdb regulatory database file' -m "https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" -s

		${git_bin} format-patch -1 -o ../patches/external/wireless_regdb/
		echo "WIRELESS_REGDB: https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" > ../patches/external/git/WIRELESS_REGDB

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

		device="AM335X-PRU-UIO-00A0" ; arm_dtbo_makefile_append
		device="BB-ADC-00A0" ; arm_dtbo_makefile_append
		device="BB-BBBW-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGG-WL1835-00A0" ; arm_dtbo_makefile_append
		device="BB-BBGW-WL1835-00A0" ; arm_dtbo_makefile_append

		device="BB-BONE-eMMC1-01-00A0" ; arm_dtbo_makefile_append

		device="BB-UART1-00A0" ; arm_dtbo_makefile_append
		device="BB-UART2-00A0" ; arm_dtbo_makefile_append
		device="BB-UART4-00A0" ; arm_dtbo_makefile_append

		device="BBORG_COMMS-00A2" ; arm_dtbo_makefile_append
		device="BBORG_FAN-A000" ; arm_dtbo_makefile_append

		device="BONE-ADC" ; arm_dtbo_makefile_append

		device="am335x-boneblack-uboot.dtb" ; arm_dtb_makefile_append
		device="am335x-boneblack-revd.dtb" ; arm_dtb_makefile_append

		device="BONE-I2C1" ; k3_dtbo_makefile_append
		device="BONE-I2C2" ; k3_dtbo_makefile_append
		device="BONE-I2C3" ; k3_dtbo_makefile_append

		device="k3-am6232-pocketbeagle2.dtb" ; k3_dtb_makefile_append

		#ls src/arm64/overlays/ | grep pocketbeagle2

		device="k3-am62-pocketbeagle2-ardupilot-cape" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-leds-off" ; k3_dtbo_makefile_append
		device="k3-am62-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append
		device="k3-am6232-pocketbeagle2-techlab-cape" ; k3_dtbo_makefile_append

		#ls src/arm64/overlays/ | grep beagleplay

		device="k3-am625-beagleplay-bcfserial-no-firmware" ; k3_dtbo_makefile_append

		#ls src/arm64/overlays/ | grep beagley

		device="k3-am67a-beagley-ai-csi0-imx219" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-csi0-ov5640" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-csi1-imx219" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-dsi-rpi-7inch-panel" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-hdmi-dss0-dpi1" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-400000" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ads1115" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-rtc-rv3028" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-i2c1-ssd1306" ; k3_dtbo_makefile_append
		device="k3-am67a-beagley-ai-lincolntech-185lcd-panel" ; k3_dtbo_makefile_append
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

		#ls src/arm64/overlays/ | grep beaglebone

		device="k3-j721e-beagleboneai64-BBORG_MOTOR" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_13-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm0-p8_19" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_14-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm2-p9_16" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-pwm-epwm4-p9_25" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi1-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi2-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi3-cs0-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0-cs1" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs0" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi6-cs1-no-miso" ; k3_dtbo_makefile_append
		device="k3-j721e-beagleboneai64-spi-mcspi7-cs0" ; k3_dtbo_makefile_append

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
	backport_tag="v6.16.1"

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

	backport_tag="v6.3"

	subsystem="it66121"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/gpu/drm/bridge/ite-it66121.c ./drivers/gpu/drm/bridge/

		post_backports
	else
		patch_backports
		#v6.15
		#git format-patch -25 drivers/gpu/drm/bridge/ite-it66121.c
		#

		#v6.2.x+
		#${git} "${DIR}/patches/mainline/ite-it66121/0001-drm-bridge-it66121-Convert-to-i2c-s-.probe_new.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0002-drm-bridge-it66121-Use-devm_regulator_bulk_get_enabl.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0003-drm-bridge-it66121-Use-regmap_noinc_read.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0004-drm-bridge-it66121-Write-AVI-infoframe-with-regmap_b.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0005-drm-bridge-it66121-Fix-wait-for-DDC-ready.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0006-drm-bridge-it66121-Don-t-use-DDC-error-IRQs.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0007-drm-bridge-it66121-Don-t-clear-DDC-FIFO-twice.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0008-drm-bridge-it66121-Set-DDC-preamble-only-once-before.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0009-drm-bridge-it66121-Move-VID-PID-to-new-it66121_chip_.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0010-drm-bridge-it66121-Add-support-for-the-IT6610.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0011-drm-bridge-Remove-unnecessary-include-statements-for.patch"

		#v6.5.x+... (not v6.1.x/v6.2.x/v6.3.x/v6.4.x)
		${git} "${DIR}/patches/mainline/ite-it66121/0012-drm-Switch-i2c-drivers-back-to-use-.probe.patch"

		#v6.7.x+
		${git} "${DIR}/patches/mainline/ite-it66121/0013-drm-bridge-it66121-Extend-match-support-for-OF-table.patch"
		#v6.1.x-lts... (not v6.2.x/v6.3.x/v6.4.x)
		${git} "${DIR}/patches/mainline/ite-it66121/0014-drm-bridge-it66121-Simplify-probe.patch"
		${git} "${DIR}/patches/mainline/ite-it66121/0015-drm-bridge-it66121-Fix-invalid-connector-dereference.patch"
		${git} "${DIR}/patches/mainline/ite-it66121/0016-drm-bridge-it66121-get_edid-callback-must-not-return.patch"

		#v6.9.x+ (disable)
		${git} "${DIR}/patches/mainline/ite-it66121/0017-drm-bridge-it66121-switch-to-edid_read-callback.patch"

		#v6.10.x+
		${git} "${DIR}/patches/mainline/ite-it66121/0018-drm-bridge-ite66121-Register-HPD-interrupt-handler-o.patch"
		${git} "${DIR}/patches/mainline/ite-it66121/0019-drm-bridge-it66121-Remove-a-duplicated-invoke-of-of_.patch"

		#v6.13.x+
		${git} "${DIR}/patches/mainline/ite-it66121/0020-drm-bridge-ite-it66121-Drop-hdmi_avi_infoframe_init-.patch"

		#v6.14.x+
		${git} "${DIR}/patches/mainline/ite-it66121/0021-drm-bridge-ite-it66121-use-eld_mutex-to-protect-acce.patch"
		${git} "${DIR}/patches/mainline/ite-it66121/0022-drm-Use-of_property_present-for-non-boolean-properti.patch"
		#(not v6.13.x)
		#${git} "${DIR}/patches/mainline/ite-it66121/0023-ASoC-hdmi-codec-move-no_capture_mute-to-struct-hdmi_.patch"

		#v6.15.x+
		#${git} "${DIR}/patches/mainline/ite-it66121/0024-drm-bridge-Pass-full-state-to-atomic_enable.patch"
		#${git} "${DIR}/patches/mainline/ite-it66121/0025-drm-bridge-Pass-full-state-to-atomic_disable.patch"
	fi

	backport_tag="rpi-6.12.y"

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

	dir 'drivers/it66121_drm_connector'
	dir 'drivers/it66122'

	dir 'drivers/wkup_m3_ipc'
	dir 'external/ti-amx3-cm3-pm-firmware'
}

###
backports
drivers

packaging () {
	echo "Update: package scripts"
	${git} "${DIR}/patches/backports/bindeb-pkg/0002-builddeb-Install-our-dtbs-under-boot-dtbs-version.patch"
}

packaging
echo "patch.sh ran successfully"
#
