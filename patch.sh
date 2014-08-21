#!/bin/sh
#
# Copyright (c) 2009-2014 Robert Nelson <robertcnelson@gmail.com>
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

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi

git="git am"
#git_patchset=""
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="git apply"
fi

echo "Starting patch.sh"

git_add () {
	git add .
	git commit -a -m 'testing patchset'
}

start_cleanup () {
	git="git am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		git format-patch -${number} -o ${DIR}/patches/
	fi
	exit
}

external_git () {
	git_tag=""
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
#local_patch

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtsi_append () {
	wfile="arch/arm/boot/dts/${base_dts}-${cape}.dts"
	cp arch/arm/boot/dts/${base_dts}.dts ${wfile}
	echo "" >> ${wfile}
	echo "#include \"am335x-bone-${cape}.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_append_hdmi_no_audio () {
	dtsi_append
	echo "#include \"am335x-boneblack-nxp-hdmi-no-audio.dtsi\"" >> ${wfile}
	git add ${wfile}
}

dtsi_drop_nxp_hdmi_audio () {
	sed -i -e 's:#include "am335x-boneblack-nxp-hdmi-no-audio.dtsi":/* #include "am335x-boneblack-nxp-hdmi-no-audio.dtsi" */:g' ${wfile}
	git add ${wfile}
}

dtsi_drop_emmc () {
	sed -i -e 's:#include "am335x-boneblack-emmc.dtsi":/* #include "am335x-boneblack-emmc.dtsi" */:g' ${wfile}
	git add ${wfile}
}

beaglebone () {
	echo "dir: beaglebone/pinmux"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
	# cp arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# gedit arch/arm/boot/dts/am335x-bone-common.dtsi arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi &
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-bone.dts &
	# git add arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
	# git commit -a -m 'am335x-bone-common: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0001-am335x-bone-common-split-out-am33xx_pinmux.patch"

	# meld arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi arch/arm/boot/dts/am335x-boneblack.dts
	# git commit -a -m 'am335x-boneblack: split out am33xx_pinmux' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0002-am335x-boneblack-split-out-am33xx_pinmux.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-emmc.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-emmc.dtsi
	# git commit -a -m 'am335x-boneblack: split out emmc' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0003-am335x-boneblack-split-out-emmc.patch"

	# cp arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi
	# gedit arch/arm/boot/dts/am335x-boneblack.dts arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi &
	# git add arch/arm/boot/dts/am335x-boneblack-nxp-hdmi-no-audio.dtsi
	# git commit -a -m 'am335x-boneblack: split out nxp hdmi no audio' -s

	${git} "${DIR}/patches/beaglebone/pinmux/0004-am335x-boneblack-split-out-nxp-hdmi-no-audio.patch"

	${git} "${DIR}/patches/beaglebone/pinmux/0005-am335x-bone-common-pinmux-i2c2.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0006-am335x-bone-common-pinmux-uart.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0007-am335x-bone-common-pinmux-spi0-spidev.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0008-am335x-bone-common-pinmux-mcasp0.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0009-am335x-bone-common-pinmux-lcd.patch"
	${git} "${DIR}/patches/beaglebone/pinmux/0010-am335x-bone-common-pinmux-tscadc-4-wire.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=10
		cleanup
	fi

	echo "dir: beaglebone/dts"
	${git} "${DIR}/patches/beaglebone/dts/0001-am335x-boneblack-add-cpu0-opp-points.patch"

	echo "dir: beaglebone/capes"
	${git} "${DIR}/patches/beaglebone/capes/0001-cape-basic-proto-cape.patch"
	${git} "${DIR}/patches/beaglebone/capes/0002-driver_n_cape-Argus-UPS-cape-support.patch"

	#regenerate="enable"
	echo "dir: beaglebone/generated"
	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="ttyO1"
		dtsi_append

		cape="ttyO2"
		dtsi_append

		cape="ttyO4"
		dtsi_append

		cape="ttyO5"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: uarts' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-cape-uarts.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="audio"
		dtsi_append

		base_dts="am335x-boneblack"
		cape="audio"
		dtsi_append

		git commit -a -m 'auto generated: cape: audio' -s
		git format-patch -2 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0002-auto-generated-cape-audio.patch"
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		base_dts="am335x-bone"
		cape="lcd3-01-00a2"
		dtsi_append

		cape="lcd4-01-00a0"
		dtsi_append
		cape="lcd4-01-00a1"
		dtsi_append

		cape="lcd7-01-00a2"
		dtsi_append
		cape="lcd7-01-00a3"
		dtsi_append

		base_dts="am335x-boneblack"
		#lcd3 a2+
		cape="lcd3-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		#lcd4 a1+
		cape="lcd4-01-00a1"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		#drop emmc:
		cape="lcd7-01-00a2"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio
		dtsi_drop_emmc

		#lcd4 a3+
		cape="lcd7-01-00a3"
		dtsi_append
		dtsi_drop_nxp_hdmi_audio

		git commit -a -m 'auto generated: cape: lcd' -s
		git format-patch -3 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0003-auto-generated-cape-lcd.patch"
	fi

	#last beaglebone/beaglebone black default
	if [ "x${regenerate}" = "xenable" ] ; then
		wfile="arch/arm/boot/dts/am335x-bone.dts"
		echo "" >> ${wfile}
		echo "/* http://elinux.org/CircuitCo:Basic_Proto_Cape */" >> ${wfile}
		echo "#include \"am335x-bone-basic-proto-cape.dtsi\"" >> ${wfile}

		wfile="arch/arm/boot/dts/am335x-boneblack.dts"
		echo "" >> ${wfile}
		echo "/* http://elinux.org/CircuitCo:Basic_Proto_Cape */" >> ${wfile}
		echo "#include \"am335x-bone-basic-proto-cape.dtsi\"" >> ${wfile}

		git commit -a -m 'auto generated: cape: basic-proto-cape' -s
		git format-patch -4 -o ../patches/beaglebone/generated/
	else
		${git} "${DIR}/patches/beaglebone/generated/0004-auto-generated-cape-basic-proto-cape.patch"
	fi

	#dtb makefile
	if [ "x${regenerate}" = "xenable" ] ; then
		device="am335x-bone-audio.dtb"
		dtb_makefile_append

		device="am335x-bone-cape-bone-argus.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd3-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd4-01-00a0.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd4-01-00a1.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd7-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-bone-lcd7-01-00a3.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO1.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO2.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO4.dtb"
		dtb_makefile_append

		device="am335x-bone-ttyO5.dtb"
		dtb_makefile_append

		device="am335x-boneblack-audio.dtb"
		dtb_makefile_append

		device="am335x-boneblack-cape-bone-argus.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd3-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd4-01-00a1.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd7-01-00a2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-lcd7-01-00a3.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO1.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO2.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO4.dtb"
		dtb_makefile_append

		device="am335x-boneblack-ttyO5.dtb"
		dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -5 -o ../patches/beaglebone/generated/
		exit
	else
		${git} "${DIR}/patches/beaglebone/generated/0005-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	echo "dir: beaglebone/power"
	${git} "${DIR}/patches/beaglebone/power/0001-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"
	${git} "${DIR}/patches/beaglebone/power/0002-am335x-bone-common-enable-ti-pmic-shutdown-controlle.patch"
	${git} "${DIR}/patches/beaglebone/power/0003-dt-bone-common-Add-interrupt-for-PMIC.patch"

	echo "dir: beaglebone/phy"
	${git} "${DIR}/patches/beaglebone/phy/0001-cpsw-Add-support-for-byte-queue-limits.patch"
	${git} "${DIR}/patches/beaglebone/phy/0002-cpsw-napi-polling-of-64-is-good-for-gigE-less-good-f.patch"
	${git} "${DIR}/patches/beaglebone/phy/0003-cpsw-search-for-phy.patch"

	echo "dir: beaglebone/mac"
	#[PATCH v4 0/7] net: cpsw: Support for am335x chip MACIDs
	${git} "${DIR}/patches/beaglebone/mac/0001-DT-doc-net-cpsw-mac-address-is-optional.patch"
	${git} "${DIR}/patches/beaglebone/mac/0002-net-cpsw-Add-missing-return-value.patch"
	${git} "${DIR}/patches/beaglebone/mac/0003-net-cpsw-header-Add-missing-include.patch"
	${git} "${DIR}/patches/beaglebone/mac/0004-net-cpsw-Replace-pr_err-by-dev_err.patch"
	${git} "${DIR}/patches/beaglebone/mac/0005-net-cpsw-Add-am33xx-MACID-readout.patch"
	${git} "${DIR}/patches/beaglebone/mac/0006-am33xx-define-syscon-control-module-device-node.patch"
	${git} "${DIR}/patches/beaglebone/mac/0007-arm-dts-am33xx-Add-syscon-phandle-to-cpsw-node.patch"

	#echo "dir: beaglebone/hdmi_audio"
	#[PATCH v2 0/8] Beaglebone-Black HDMI audio
	#${git} "${DIR}/patches/beaglebone/hdmi_audio/0001-clk-ti-add-gpio-controlled-clock.patch"
	#${git} "${DIR}/patches/beaglebone/hdmi_audio/0002-drm-tilcdc-Add-I2S-HDMI-audio-config-for-tda998x.patch"
	#${git} "${DIR}/patches/beaglebone/hdmi_audio/0003-ASoC-davinci-evm-HDMI-audio-support-for-TDA998x-trou.patch"
	#${git} "${DIR}/patches/beaglebone/hdmi_audio/0004-ASoC-davinci-HDMI-audio-build-for-AM33XX-and-TDA998x.patch"
	#${git} "${DIR}/patches/beaglebone/hdmi_audio/0005-ARM-dts-am33xx-Add-external-clock-provider.patch"
}

sgx () {
	echo "dir: sgx"
	${git} "${DIR}/patches/sgx/0001-HACK-drm-fb_helper-enable-panning-support.patch"
	${git} "${DIR}/patches/sgx/0002-HACK-drm-tilcdc-add-vsync-callback-for-use-in-omaplf.patch"
	${git} "${DIR}/patches/sgx/0003-drm-tilcdc-fix-the-ping-pong-dma-tearing-issue-seen-.patch"
	${git} "${DIR}/patches/sgx/0004-ARM-OMAP2-Use-pdata-quirks-for-sgx-deassert_hardrese.patch"
	${git} "${DIR}/patches/sgx/0005-ARM-dts-am33xx-add-DT-node-for-gpu.patch"
	${git} "${DIR}/patches/sgx/0006-arm-Export-cache-flush-management-symbols-when-MULTI.patch"
}

rt () {
	echo "dir: rt"
	${git} "${DIR}/patches/rt/0001-rt-3.14-patchset.patch"
}

###
beaglebone
sgx

#disabled by default
#rt

packaging_setup () {
	cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
	git commit -a -m 'packaging: sync with mainline' -s

	git format-patch -1 -o "${DIR}/patches/packaging"
}

packaging () {
	echo "dir: packaging"
	#${git} "${DIR}/patches/packaging/0001-packaging-sync-with-mainline.patch"
	${git} "${DIR}/patches/packaging/0002-deb-pkg-install-dtbs-in-linux-image-package.patch"
	#${git} "${DIR}/patches/packaging/0003-deb-pkg-no-dtbs_install.patch"
}

#packaging_setup
packaging
echo "patch.sh ran successful"
