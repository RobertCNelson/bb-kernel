#!/bin/bash -e
#
# Copyright (c) 2009-2016 Robert Nelson <robertcnelson@gmail.com>
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

pick () {
	if [ ! -d ../patches/${pick_dir} ] ; then
		mkdir -p ../patches/${pick_dir}
	fi
	${git_bin} format-patch -1 ${SHA} --start-number ${num} -o ../patches/${pick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag=""
	echo "pulling: ${git_tag}"
	${git_bin} pull --no-edit ${git_patchset} ${git_tag}
	${git_bin} describe
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		${git_bin} format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
#rt
#local_patch

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/reverts/0001-Revert-ARM-dts-am335x-boneblack-disable-RTC-only-sle.patch"
	${git} "${DIR}/patches/reverts/0002-Revert-spi-spidev-Warn-loudly-if-instantiated-from-D.patch"
#	#udoo:
#	${git} "${DIR}/patches/reverts/0003-Revert-usb-chipidea-usbmisc_imx-delete-clock-informa.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi
}

backports () {
	echo "dir: backports"
	echo "dir: backports/mediatek"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#careful around: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/wireless/mediatek?id=30686bf7f5b3c30831761e188a6e3cb33580fa48
	${git} "${DIR}/patches/backports/mediatek/0001-backport-mediatek-mt7601u-from-v4.2-rc3.patch"
	${git} "${DIR}/patches/backports/0002-backport-drivers-staging-fbtft-v4.3.0.patch"
	${git} "${DIR}/patches/backports/0003-backport-fbtft-v4.4-rc1.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi
}

fixes () {
	echo "dir: fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

ti () {
	echo "dir: ti/cpu_freq/"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/ti/cpu_freq/0001-ARM-OMAP2-opp-Move-dt-check-from-omap_init_opp_table.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0002-ARM-OMAP2-opp-Add-helper-functions-for-variable-OPP-.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0003-ARM-OMAP2-AM33XX-Add-opp33xx_data-to-enable-higher-O.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0004-ARM-OMAP2-AM43XX-Add-opp43xx_data-to-enable-higher-O.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0005-ARM-OMAP2-DRA7XX-Add-opp7xx_data-to-enable-higher-OP.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0006-ARM-dts-am33xx-Drop-operating-points-table-from-cpu0.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0007-ARM-dts-am4372-Add-voltage-tolerance-to-cpu-node.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0008-ARM-dts-am43x-epos-evm-Hook-dcdc2-as-the-cpu0-supply.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0009-ARM-dts-am437x-gp-evm-Hook-dcdc2-as-the-cpu0-supply.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0010-ARM-dts-dra72x-add-clock-nodes-for-CPU.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0011-ARM-dts-dra72x-Add-basic-OPPs-for-MPU.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0012-ARM-dts-dra74x-Remove-non-common-cpu0-operating-poin.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0013-PM-Voltagedomain-Add-generic-clk-notifier-handler-fo.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0014-PM-Voltagedomain-introduce-voltage-domain-driver-sup.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0015-PM-Voltagedomain-introduce-basic-voltage-domain-supp.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0016-cpufreq-cpufreq-voltdm-Split-cpufreq-dt-to-use-clk-r.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0017-ARM-OMAP2-pm-Change-cpufreq-platform-device-to-cpufr.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0018-cpufreq-voltdm-use-the-right-device-node-for-resourc.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0019-cpufreq-voltdm-do-a-dummy-opp-setup-as-part-of-probe.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0020-ARM-dts-OMAP5-Add-voltage-domains.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0021-ARM-dts-omap5uevm-Add-vdd-regulators-for-voltage-dom.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0022-ARM-dts-dra7-add-voltage-domains.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0023-ARM-dts-dra7-evm-Add-vdd-regulators-for-voltage-doma.patch"
	${git} "${DIR}/patches/ti/cpu_freq/0024-ARM-dts-dra72-evm-Add-mapping-of-voltage-domains-to-.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=24
		cleanup
	fi

	echo "dir: ti/iodelay/"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/ti/iodelay/0001-ARM-dts-am57xx-beagle-x15-Map-regulators-to-voltage-.patch"
	${git} "${DIR}/patches/ti/iodelay/0002-pinctrl-bindings-pinctrl-Add-support-for-TI-s-IODela.patch"
	${git} "${DIR}/patches/ti/iodelay/0003-pinctrl-Introduce-TI-IOdelay-configuration-driver.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi
}

pru () {
	echo "dir: pru"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/pru/0001-Making-the-uio-pruss-driver-work.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

mainline () {
	git format-patch -1 ${SHA} --start-number ${num} -o ../patches/bbb_overlays/mainline/
}

bbb_overlays () {
	echo "dir: bbb_overlays/dtc"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ -d dtc ] ; then
			rm -rf dtc
		fi
		git clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git
		cd dtc
		git pull --no-edit https://github.com/pantoniou/dtc dt-overlays5

		cd ../KERNEL/
		sed -i -e 's:git commit:#git commit:g' ./scripts/dtc/update-dtc-source.sh
		./scripts/dtc/update-dtc-source.sh
		sed -i -e 's:#git commit:git commit:g' ./scripts/dtc/update-dtc-source.sh
		git commit -a -m "scripts/dtc: Update to upstream version overlays" -s
		git format-patch -1 -o ../patches/bbb_overlays/dtc/
		exit 2
	else
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		${git} "${DIR}/patches/bbb_overlays/dtc/0001-scripts-dtc-Update-to-upstream-version-overlays.patch"

		if [ "x${regenerate}" = "xenable" ] ; then
			number=1
			cleanup
		fi
	fi

	echo "dir: bbb_overlays/mainline"

	${git} "${DIR}/patches/bbb_overlays/mainline/0001-regmap-Introduce-regmap_get_max_register.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0002-regmap-Introduce-regmap_get_reg_stride.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0003-ARM-dts-Beaglebone-i2c-definitions.patch"
	${git} "${DIR}/patches/bbb_overlays/mainline/0004-i2c-Mark-instantiated-device-nodes-with-OF_POPULATE.patch"

	echo "dir: bbb_overlays/nvmem"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bbb_overlays/nvmem/0001-nvmem-Add-a-simple-NVMEM-framework-for-nvmem-provide.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0002-nvmem-Add-a-simple-NVMEM-framework-for-consumers.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0003-nvmem-Add-nvmem_device-based-consumer-apis.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0004-nvmem-Add-bindings-for-simple-nvmem-framework.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0005-Documentation-nvmem-add-nvmem-api-level-and-how-to-d.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0006-nvmem-qfprom-Add-Qualcomm-QFPROM-support.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0007-nvmem-qfprom-Add-bindings-for-qfprom.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0008-nvmem-sunxi-Move-the-SID-driver-to-the-nvmem-framewo.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0009-nvmem-Add-DT-binding-documentation-for-Vybrid-OCOTP-.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0010-nvmem-Add-Vybrid-OCOTP-support.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0011-nvmem-Add-i.MX6-OCOTP-device-tree-binding-documentat.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0012-nvmem-imx-ocotp-Add-i.MX6-OCOTP-driver.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0013-nvmem-add-binding-for-mxs-ocotp.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0014-nvmem-add-driver-for-ocotp-in-i.MX23-and-i.MX28.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0015-nvmem-rockchip-efuse-describe-the-usage-of-eFuse.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0016-nvmem-Adding-bindings-for-rockchip-efuse.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0017-nvmem-rockchip_efuse_regmap_config-can-be-static.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0018-nvmem-core-fix-the-out-of-range-leak-in-read-write.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0019-nvmem-core-Handle-shift-bits-in-place-if-cell-nbits-.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0020-nvmem-core-Fix-memory-leak-in-nvmem_cell_write.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0021-nvmem-sunxi-Check-for-memory-allocation-failure.patch"

#email...

	${git} "${DIR}/patches/bbb_overlays/nvmem/0022-nvmem-make-default-user-binary-file-root-access-only.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0023-nvmem-set-the-size-for-the-nvmem-binary-file.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0024-nvmem-add-permission-flags-in-nvmem_config.patch"
	${git} "${DIR}/patches/bbb_overlays/nvmem/0025-nvmem-fix-permissions-of-readonly-nvmem-binattr.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=25
		cleanup
	fi

	echo "dir: bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bbb_overlays/0001-configfs-Implement-binary-attributes-v4.patch"
	${git} "${DIR}/patches/bbb_overlays/0002-OF-DT-Overlay-configfs-interface-v5.patch"
	${git} "${DIR}/patches/bbb_overlays/0003-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0004-add-PM-firmware.patch"
	${git} "${DIR}/patches/bbb_overlays/0005-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	${git} "${DIR}/patches/bbb_overlays/0006-arm-omap-Proper-cleanups-for-omap_device.patch"
	${git} "${DIR}/patches/bbb_overlays/0007-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/bbb_overlays/0008-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/bbb_overlays/0009-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"
	${git} "${DIR}/patches/bbb_overlays/0010-of-Custom-printk-format-specifier-for-device-node.patch"
	${git} "${DIR}/patches/bbb_overlays/0011-of-overlay-kobjectify-overlay-objects.patch"
	${git} "${DIR}/patches/bbb_overlays/0012-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/bbb_overlays/0013-of-overlay-add-per-overlay-sysfs-attributes.patch"
	${git} "${DIR}/patches/bbb_overlays/0014-Documentation-ABI-sys-firmware-devicetree-overlays.patch"
	${git} "${DIR}/patches/bbb_overlays/0015-i2c-nvmem-at24-Provide-an-EEPROM-framework-interface.patch"
	${git} "${DIR}/patches/bbb_overlays/0016-misc-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/bbb_overlays/0017-doc-misc-Beaglebone-capemanager-documentation.patch"
	${git} "${DIR}/patches/bbb_overlays/0018-doc-dt-beaglebone-cape-manager-bindings.patch"
	${git} "${DIR}/patches/bbb_overlays/0019-doc-ABI-bone_capemgr-sysfs-API.patch"
	${git} "${DIR}/patches/bbb_overlays/0020-MAINTAINERS-Beaglebone-capemanager-maintainer.patch"
	${git} "${DIR}/patches/bbb_overlays/0021-arm-dts-Enable-beaglebone-cape-manager.patch"
	${git} "${DIR}/patches/bbb_overlays/0022-of-overlay-Implement-indirect-target-support.patch"
	${git} "${DIR}/patches/bbb_overlays/0023-of-unittest-Add-indirect-overlay-target-test.patch"
	${git} "${DIR}/patches/bbb_overlays/0024-doc-dt-Document-the-indirect-overlay-method.patch"
	${git} "${DIR}/patches/bbb_overlays/0025-of-overlay-Introduce-target-root-capability.patch"
	${git} "${DIR}/patches/bbb_overlays/0026-of-unittest-Unit-tests-for-target-root-overlays.patch"
	${git} "${DIR}/patches/bbb_overlays/0027-doc-dt-Document-the-target-root-overlay-method.patch"
	${git} "${DIR}/patches/bbb_overlays/0028-of-dynamic-Add-__of_node_dupv.patch"
	${git} "${DIR}/patches/bbb_overlays/0029-of-changesets-Introduce-changeset-helper-methods.patch"
	${git} "${DIR}/patches/bbb_overlays/0030-RFC-Device-overlay-manager-PCI-USB-DT.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/bbb_overlays/0031-boneblack-defconfig.patch"
	fi

	${git} "${DIR}/patches/bbb_overlays/0033-bone_capemgr-uboot_capemgr_enabled-flag.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=32
		cleanup
	fi
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beaglebone () {
	echo "dir: beaglebone/dts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#${git} "${DIR}/patches/beaglebone/dts/0001-am335x-boneblack-add-cpu0-opp-points.patch"
	${git} "${DIR}/patches/beaglebone/dts/0001-hack-bbb-enable-1ghz-operation.patch"
	${git} "${DIR}/patches/beaglebone/dts/0002-dts-am335x-bone-common-fixup-leds-to-match-3.8.patch"
	${git} "${DIR}/patches/beaglebone/dts/0003-arm-dts-am335x-bone-common-add-collision-and-carrier.patch"
	${git} "${DIR}/patches/beaglebone/dts/0004-add-am335x-bonegreen.patch"
	${git} "${DIR}/patches/beaglebone/dts/0005-add-overlay-dtb.patch"
	${git} "${DIR}/patches/beaglebone/dts/0006-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"
	${git} "${DIR}/patches/beaglebone/dts/0007-spi-omap2-mcspi-ti-pio-mode.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=7
		cleanup
	fi

	echo "dir: beaglebone/capes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/capes/0001-cape-Argus-UPS-cape-support.patch"
	${git} "${DIR}/patches/beaglebone/capes/0002-Added-support-for-Replicape.patch"
	${git} "${DIR}/patches/beaglebone/capes/0003-ARM-dts-am335x-boneblack-enable-wl1835mod-cape-suppo.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi

	echo "dir: beaglebone/pinmux-helper"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/pinmux-helper/0001-BeagleBone-pinmux-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0002-pinmux-helper-Add-runtime-configuration-capability.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0003-pinmux-helper-Switch-to-using-kmalloc.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0004-gpio-Introduce-GPIO-OF-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0005-Add-dir-changeable-property-to-gpio-of-helper.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0006-am33xx.dtsi-add-ocp-label.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0007-beaglebone-added-expansion-header-to-dtb.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0008-bone-pinmux-helper-Add-support-for-mode-device-tree-.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0009-pinmux-helper-add-P8_37_pinmux-P8_38_pinmux.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0010-pinmux-helper-hdmi.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0011-pinmux-helper-can1.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0012-Remove-CONFIG_EXPERIMENTAL-dependency-on-CONFIG_GPIO.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0013-pinmux-helper-add-P9_19_pinmux-P9_20_pinmux.patch"
	${git} "${DIR}/patches/beaglebone/pinmux-helper/0014-gpio-of-helper-idr_alloc.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=14
		cleanup
	fi

	echo "dir: beaglebone/eqep"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/eqep/0001-Provides-a-sysfs-interface-to-the-eQEP-hardware-on-t.patch"
	${git} "${DIR}/patches/beaglebone/eqep/0002-tieqep.c-devres-remove-devm_request_and_ioremap.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi

	#This has to be last...
	echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi
	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	####
	#dtb makefile
	echo "dir: beaglebone/generated"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		device="am335x-arduino-tre.dtb" ; dtb_makefile_append

		device="am335x-bone-cape-bone-argus.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append
		device="am335x-boneblack-cape-bone-argus.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append

		device="am335x-boneblack-emmc-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-hdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-nhdmi-overlay.dtb" ; dtb_makefile_append
		device="am335x-boneblack-overlay.dtb" ; dtb_makefile_append

		device="am335x-boneblack-replicape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append

		device="am335x-bonegreen-overlay.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi

	echo "dir: beaglebone/phy"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/phy/0001-cpsw-Add-support-for-byte-queue-limits.patch"
	${git} "${DIR}/patches/beaglebone/phy/0002-cpsw-napi-polling-of-64-is-good-for-gigE-less-good-f.patch"
	${git} "${DIR}/patches/beaglebone/phy/0003-cpsw-search-for-phy.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=3
		cleanup
	fi

	echo "dir: beaglebone/remoteproc"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/remoteproc/0001-remoteproc-ste-add-blank-lines-after-declarations.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0002-remoteproc-davinci-fix-quoted-split-string-checkpatc.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0003-remoteproc-fix-various-checkpatch-warnings.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0004-remoteproc-introduce-rproc_get_by_phandle-API.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0005-remoteproc-add-a-rproc-ops-for-performing-address-tr.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0006-Documentation-dt-add-bindings-for-TI-Wakeup-M3-proce.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0007-remoteproc-wkup_m3-add-a-remoteproc-driver-for-TI-Wa.patch"
	${git} "${DIR}/patches/beaglebone/remoteproc/0008-remoteproc-fix-CONFIG_OF-build-breakage.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=8
		cleanup
	fi

	echo "dir: beaglebone/firmware"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#http://git.ti.com/gitweb/?p=ti-cm3-pm-firmware/amx3-cm3.git;a=summary
	#git clone git://git.ti.com/ti-cm3-pm-firmware/amx3-cm3.git
	#cd amx3-cm3/
	#git checkout origin/ti-v4.1.y -b tmp

	#commit 730f0695ca2dda65abcff5763e8f108517bc0d43
	#Author: Dave Gerlach <d-gerlach@ti.com>
	#Date:   Wed Mar 4 21:34:54 2015 -0600
	#
	#    CM3: Bump firmware release to 0x191
	#    
	#    This version, 0x191, includes the following changes:
	#         - Add trace output on boot for kernel remoteproc driver
	#         - Fix resouce table as RSC_INTMEM is no longer used in kernel
	#         - Add header dependency checking
	#    
	#    Signed-off-by: Dave Gerlach <d-gerlach@ti.com>

	#cp -v bin/am* /opt/github/linux-dev/KERNEL/firmware/

	#git add -f ./firmware/am*

	${git} "${DIR}/patches/beaglebone/firmware/0001-add-am33x-firmware.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	echo "dir: beaglebone/hwspinlock"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/hwspinlock/0001-Documentation-dt-add-common-bindings-for-hwspinlock.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0002-hwspinlock-core-add-device-tree-support.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0003-Documentation-dt-add-the-omap-hwspinlock-bindings-do.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0004-hwspinlock-omap-add-support-for-dt-nodes.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0005-DT-hwspinlock-Add-binding-documentation-for-Qualcomm.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0006-hwspinlock-qcom-Add-support-for-Qualcomm-HW-Mutex-bl.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0007-hwspinlock-add-a-CSR-atlas7-driver.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0008-DT-hwspinlock-add-the-CSR-atlas7-hwspinlock-bindings.patch"
	${git} "${DIR}/patches/beaglebone/hwspinlock/0009-hwspinlock-qcom-Correct-msb-in-regmap_field.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=9
		cleanup
	fi

}

quieter () {
	echo "dir: quieter"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/quieter/0001-quiet-8250_omap.c-use-pr_info-over-pr_err.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

sgx () {
	echo "dir: sgx"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/sgx/0001-HACK-drm-fb_helper-enable-panning-support.patch"
	${git} "${DIR}/patches/sgx/0002-HACK-drm-tilcdc-add-vsync-callback-for-use-in-omaplf.patch"
	${git} "${DIR}/patches/sgx/0003-drm-tilcdc-fix-the-ping-pong-dma-tearing-issue-seen-.patch"
	${git} "${DIR}/patches/sgx/0004-ARM-OMAP2-Use-pdata-quirks-for-sgx-deassert_hardrese.patch"
	${git} "${DIR}/patches/sgx/0005-ARM-dts-am33xx-add-DT-node-for-gpu.patch"
	${git} "${DIR}/patches/sgx/0006-arm-Export-cache-flush-management-symbols-when-MULTI.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=6
		cleanup
	fi
}

sync_mainline_dtc () {
	echo "dir: dtc"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./dtc ] ; then
			${git_bin} clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git
			cd ./dtc
			${git_bin} checkout origin/master -b tmp
			cd ../
		else
			rm -rf ./dtc || true
			${git_bin} clone https://git.kernel.org/pub/scm/utils/dtc/dtc.git
			cd ./dtc
			${git_bin} checkout origin/master -b tmp
			cd ../
		fi
		cd ./KERNEL/

		sed -i -e 's:git commit:#git commit:g' ./scripts/dtc/update-dtc-source.sh
		./scripts/dtc/update-dtc-source.sh
		sed -i -e 's:#git commit:git commit:g' ./scripts/dtc/update-dtc-source.sh
		git commit -a -m "scripts/dtc: Update to upstream version overlays" -s
		git format-patch -1 -o ../patches/dtc/

		rm -rf ../dtc/ || true

		exit 2
	else
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		${git} "${DIR}/patches/dtc/0001-scripts-dtc-Update-to-upstream-version-overlays.patch"
		${git} "${DIR}/patches/dtc/0002-dtc-turn-off-dtc-unit-address-warnings-by-default.patch"
		${git} "${DIR}/patches/dtc/0003-ARM-boot-Add-an-implementation-of-strnlen-for-libfdt.patch"

		if [ "x${regenerate}" = "xenable" ] ; then
			wdir="dtc"
			number=3
			cleanup
		fi
	fi
}

###
reverts
backports
ti
#fixes
pru
bbb_overlays
beaglebone
quieter
sgx
sync_mainline_dtc

dir 'fixes/2022'

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		${git_bin} commit -a -m 'packaging: sync builddeb changes' -s
		${git_bin} format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

packaging
echo "patch.sh ran successfully"
