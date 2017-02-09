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

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
#local_patch

am33x () {
	echo "dir: dma"
	${git} "${DIR}/patches/dma/0001-Without-MACH_-option-Early-printk-DEBUG_LL.patch"
	${git} "${DIR}/patches/dma/0002-ARM-OMAP-Hack-AM33xx-clock-data-to-allow-JTAG-use.patch"
	${git} "${DIR}/patches/dma/0003-video-st7735fb-add-st7735-framebuffer-driver.patch"
	${git} "${DIR}/patches/dma/0004-dmaengine-add-helper-function-to-request-a-slave-DMA.patch"
	${git} "${DIR}/patches/dma/0005-of-Add-generic-device-tree-DMA-helpers.patch"
	${git} "${DIR}/patches/dma/0006-of-dma-fix-build-break-for-CONFIG_OF.patch"
	${git} "${DIR}/patches/dma/0007-of-dma-fix-typos-in-generic-dma-binding-definition.patch"
	${git} "${DIR}/patches/dma/0008-dmaengine-fix-build-failure-due-to-missing-semi-colo.patch"
	${git} "${DIR}/patches/dma/0009-dmaengine-edma-fix-slave-config-dependency-on-direct.patch"
	${git} "${DIR}/patches/dma/0010-dmaengine-add-dma_get_channel_caps.patch"
	${git} "${DIR}/patches/dma/0011-dma-edma-add-device_channel_caps-support.patch"
	${git} "${DIR}/patches/dma/0012-mmc-davinci-get-SG-segment-limits-with-dma_get_chann.patch"
	${git} "${DIR}/patches/dma/0013-ARM-davinci-move-private-EDMA-API-to-arm-common.patch"
	${git} "${DIR}/patches/dma/0014-ARM-edma-remove-unused-transfer-controller-handlers.patch"
	${git} "${DIR}/patches/dma/0015-ARM-edma-add-AM33XX-support-to-the-private-EDMA-API.patch"
	${git} "${DIR}/patches/dma/0016-dmaengine-edma-enable-build-for-AM33XX.patch"
	${git} "${DIR}/patches/dma/0017-dmaengine-edma-Add-TI-EDMA-device-tree-binding.patch"
	${git} "${DIR}/patches/dma/0018-ARM-dts-add-AM33XX-EDMA-support.patch"
	${git} "${DIR}/patches/dma/0019-dmaengine-add-dma_request_slave_channel_compat.patch"
	${git} "${DIR}/patches/dma/0020-mmc-omap_hsmmc-convert-to-dma_request_slave_channel_.patch"
	${git} "${DIR}/patches/dma/0021-mmc-omap_hsmmc-set-max_segs-based-on-dma-engine-limi.patch"
	${git} "${DIR}/patches/dma/0022-mmc-omap_hsmmc-add-generic-DMA-request-support-to-th.patch"
	${git} "${DIR}/patches/dma/0023-ARM-dts-add-AM33XX-MMC-support.patch"
	${git} "${DIR}/patches/dma/0024-spi-omap2-mcspi-convert-to-dma_request_slave_channel.patch"
	${git} "${DIR}/patches/dma/0025-spi-omap2-mcspi-add-generic-DMA-request-support-to-t.patch"
	${git} "${DIR}/patches/dma/0026-ARM-dts-add-AM33XX-SPI-DMA-support.patch"
	${git} "${DIR}/patches/dma/0027-ARM-dts-Add-SPI-Flash-support-to-am335x-evm.patch"
	${git} "${DIR}/patches/dma/0028-Documentation-bindings-add-spansion.patch"
	${git} "${DIR}/patches/dma/0029-ARM-dts-enable-spi1-node-and-pinmux-on-BeagleBone.patch"
	${git} "${DIR}/patches/dma/0030-ARM-dts-add-BeagleBone-Adafruit-1.8-LCD-support.patch"
	${git} "${DIR}/patches/dma/0031-misc-add-gpevt-driver.patch"
	${git} "${DIR}/patches/dma/0032-ARM-dts-add-BeagleBone-gpevt-support.patch"
	${git} "${DIR}/patches/dma/0033-ARM-configs-working-dmaengine-configs-for-da8xx-and-.patch"
	${git} "${DIR}/patches/dma/0034-ARM-dts-Add-UART4-support-to-BeagleBone.patch"
	${git} "${DIR}/patches/dma/0035-gpevnt-Remove-__devinit.patch"

	echo "dir: rtc"
	${git} "${DIR}/patches/rtc/0001-ARM-OMAP2-am33xx-hwmod-Fix-register-offset-NULL-chec.patch"
	${git} "${DIR}/patches/rtc/0002-rtc-OMAP-Add-system-pm_power_off-to-rtc-driver.patch"
	${git} "${DIR}/patches/rtc/0003-ARM-dts-AM33XX-Set-pmic-shutdown-controller-for-Beag.patch"
	${git} "${DIR}/patches/rtc/0004-ARM-dts-AM33XX-Enable-system-power-off-control-in-am.patch"

	echo "dir: pinctrl"
	${git} "${DIR}/patches/pinctrl/0001-i2c-pinctrl-ify-i2c-omap.c.patch"
	${git} "${DIR}/patches/pinctrl/0002-arm-dts-AM33XX-Configure-pinmuxs-for-user-leds-contr.patch"
	${git} "${DIR}/patches/pinctrl/0003-beaglebone-DT-set-default-triggers-for-LEDS.patch"
	${git} "${DIR}/patches/pinctrl/0004-beaglebone-add-a-cpu-led-trigger.patch"

	echo "dir: cpufreq"
	${git} "${DIR}/patches/cpufreq/0001-am33xx-DT-add-commented-out-OPP-values-for-ES2.0.patch"

	echo "dir: adc"
	${git} "${DIR}/patches/adc/0001-mfd-input-iio-ti_am335x_adc-use-one-structure-for-ti.patch"
	${git} "${DIR}/patches/adc/0002-input-ti_am33x_tsc-Step-enable-bits-made-configurabl.patch"
	${git} "${DIR}/patches/adc/0003-input-ti_am33x_tsc-Order-of-TSC-wires-made-configura.patch"
	${git} "${DIR}/patches/adc/0004-input-ti_am33x_tsc-remove-unwanted-fifo-flush.patch"
	${git} "${DIR}/patches/adc/0005-input-ti_am33x_tsc-Add-DT-support.patch"
	${git} "${DIR}/patches/adc/0006-iio-ti_am335x_adc-Add-DT-support.patch"
	${git} "${DIR}/patches/adc/0007-arm-dts-AM335x-evm-Add-TSC-ADC-MFD-device-support.patch"
	${git} "${DIR}/patches/adc/0008-mfd-ti_am335x_tscadc-Add-DT-support.patch"
	${git} "${DIR}/patches/adc/0009-iio-ti_tscadc-provide-datasheet_name-and-scan_type.patch"
	${git} "${DIR}/patches/adc/0010-mfd-ti_tscadc-deal-with-partial-activation.patch"
	${git} "${DIR}/patches/adc/0011-input-ti_am335x_adc-use-only-FIFO0-and-clean-up-a-li.patch"
	${git} "${DIR}/patches/adc/0012-input-ti_am335x_tsc-ACK-the-HW_PEN-irq-in-ISR.patch"
	${git} "${DIR}/patches/adc/0013-input-ti_am335x_tsc-return-IRQ_NONE-if-there-was-no-.patch"
	${git} "${DIR}/patches/adc/0014-iio-ti_am335x_adc-Allow-to-specify-input-line.patch"
	${git} "${DIR}/patches/adc/0015-iio-ti_am335x_adc-check-if-we-found-the-value.patch"
	${git} "${DIR}/patches/adc/0016-MFD-ti_tscadc-disable-TSC-control-register-bits-when.patch"
	${git} "${DIR}/patches/adc/0017-IIO-ADC-ti_adc-Fix-1st-sample-read.patch"
	${git} "${DIR}/patches/adc/0018-input-ti_tsc-Enable-shared-IRQ-TSC.patch"
	${git} "${DIR}/patches/adc/0019-iio-ti_am335x_adc-Add-IIO-map-interface.patch"

	echo "dir: i2c"
	${git} "${DIR}/patches/i2c/0001-pinctrl-pinctrl-single-must-be-initialized-early.patch"
	${git} "${DIR}/patches/i2c/0002-Bone-DTS-working-i2c2-i2c3-in-the-tree.patch"
	${git} "${DIR}/patches/i2c/0003-am33xx-Convert-I2C-from-omap-to-am33xx-names.patch"
	${git} "${DIR}/patches/i2c/0004-am335x-evm-hack-around-i2c-node-names.patch"
	${git} "${DIR}/patches/i2c/0005-tsl2550-fix-lux1_input-error-in-low-light.patch"

	echo "dir: da8xx-fb"
	${git} "${DIR}/patches/da8xx-fb/0001-viafb-rename-display_timing-to-via_display_timing.patch"
	${git} "${DIR}/patches/da8xx-fb/0002-video-add-display_timing-and-videomode.patch"
	${git} "${DIR}/patches/da8xx-fb/0003-video-add-of-helper-for-display-timings-videomode.patch"
	${git} "${DIR}/patches/da8xx-fb/0004-fbmon-add-videomode-helpers.patch"
	${git} "${DIR}/patches/da8xx-fb/0005-fbmon-add-of_videomode-helpers.patch"
	${git} "${DIR}/patches/da8xx-fb/0006-drm_modes-add-videomode-helpers.patch"
	${git} "${DIR}/patches/da8xx-fb/0007-drm_modes-add-of_videomode-helpers.patch"
	${git} "${DIR}/patches/da8xx-fb/0008-fbmon-fix-build-error.patch"
	${git} "${DIR}/patches/da8xx-fb/0009-of-display-timings-use-of_get_child_by_name.patch"
	${git} "${DIR}/patches/da8xx-fb/0010-da8xx-Allow-use-by-am33xx-based-devices.patch"
	${git} "${DIR}/patches/da8xx-fb/0011-video-da8xx-fb-fb_check_var-enhancement.patch"
	${git} "${DIR}/patches/da8xx-fb/0012-video-da8xx-fb-simplify-lcd_reset.patch"
	${git} "${DIR}/patches/da8xx-fb/0013-video-da8xx-fb-use-modedb-helper-to-update-var.patch"
	${git} "${DIR}/patches/da8xx-fb/0014-video-da8xx-fb-remove-unneeded-var-initialization.patch"
	${git} "${DIR}/patches/da8xx-fb/0015-video-da8xx-fb-store-current-display-information.patch"
	${git} "${DIR}/patches/da8xx-fb/0016-video-da8xx-fb-store-clk-rate-even-if-CPUFREQ.patch"
	${git} "${DIR}/patches/da8xx-fb/0017-video-da8xx-fb-pix-clk-and-clk-div-handling-cleanup.patch"
	${git} "${DIR}/patches/da8xx-fb/0018-video-da8xx-fb-store-struct-device.patch"
	${git} "${DIR}/patches/da8xx-fb/0019-video-da8xx-fb-report-correct-pixclock.patch"
	${git} "${DIR}/patches/da8xx-fb/0020-video-da8xx-fb-fb_set_par-support.patch"
	${git} "${DIR}/patches/da8xx-fb/0021-ARM-dts-AM33XX-Add-lcdc-node.patch"
	${git} "${DIR}/patches/da8xx-fb/0022-ARM-dts-AM33XX-Add-am335x-evm-lcdc-panel-timings.patch"
	${git} "${DIR}/patches/da8xx-fb/0023-ARM-dts-AM33XX-Add-am335x-evm-lcdc-pincontrol-info.patch"
	${git} "${DIR}/patches/da8xx-fb/0024-ARM-dts-AM33XX-Add-am335x-evmsk-lcdc-panel-timings.patch"
	${git} "${DIR}/patches/da8xx-fb/0025-ARM-dts-AM33XX-Add-am335x-evmsk-lcdc-pincontrol-info.patch"
	${git} "${DIR}/patches/da8xx-fb/0026-ARM-OMAP-AM33xx-hwmod-Corrects-PWM-subsystem-HWMOD-e.patch"
	${git} "${DIR}/patches/da8xx-fb/0027-ARM-OMAP-AM33xx-hwmod-Add-parent-child-relationship-.patch"
	${git} "${DIR}/patches/da8xx-fb/0028-ARM-dts-AM33XX-Add-PWMSS-device-tree-nodes.patch"
	${git} "${DIR}/patches/da8xx-fb/0029-ARM-dts-AM33XX-Add-PWM-backlight-DT-data-to-am335x-e.patch"
	${git} "${DIR}/patches/da8xx-fb/0030-ARM-dts-AM33XX-Add-PWM-backlight-DT-data-to-am335x-e.patch"
	${git} "${DIR}/patches/da8xx-fb/0031-clk-divider-prepare-for-minimum-divider.patch"
	${git} "${DIR}/patches/da8xx-fb/0032-clk-divider-handle-minimum-divider.patch"
	${git} "${DIR}/patches/da8xx-fb/0033-ARM-OMAP2-dpll-round-rate-to-closest-value.patch"
	${git} "${DIR}/patches/da8xx-fb/0034-ARM-OMAP2-dpll-am335x-avoid-freqsel.patch"
	${git} "${DIR}/patches/da8xx-fb/0035-ARM-OMAP2-clock-DEFINE_STRUCT_CLK_FLAGS-helper.patch"
	${git} "${DIR}/patches/da8xx-fb/0036-ARM-AM33XX-clock-SET_RATE_PARENT-in-lcd-path.patch"
	${git} "${DIR}/patches/da8xx-fb/0037-video-da8xx-fb-make-io-operations-safe.patch"
	${git} "${DIR}/patches/da8xx-fb/0038-video-da8xx-fb-fix-24bpp-raster-configuration.patch"
	${git} "${DIR}/patches/da8xx-fb/0039-video-da8xx-fb-enable-sync-lost-intr-for-v2-ip.patch"
	${git} "${DIR}/patches/da8xx-fb/0040-video-da8xx-fb-use-devres.patch"
	${git} "${DIR}/patches/da8xx-fb/0041-video-da8xx-fb-ensure-non-null-cfg-in-pdata.patch"
	${git} "${DIR}/patches/da8xx-fb/0042-video-da8xx-fb-reorganize-panel-detection.patch"
	${git} "${DIR}/patches/da8xx-fb/0043-video-da8xx-fb-minimal-dt-support.patch"
	${git} "${DIR}/patches/da8xx-fb/0044-video-da8xx-fb-invoke-platform-callback-safely.patch"
	${git} "${DIR}/patches/da8xx-fb/0045-video-da8xx-fb-obtain-fb_videomode-info-from-dt.patch"
	${git} "${DIR}/patches/da8xx-fb/0046-video-da8xx-fb-ensure-pdata-only-for-non-dt.patch"
	${git} "${DIR}/patches/da8xx-fb/0047-video-da8xx-fb-setup-struct-lcd_ctrl_config-for-dt.patch"
	${git} "${DIR}/patches/da8xx-fb/0048-video-da8xx-fb-CCF-clock-divider-handling.patch"

	echo "dir: pwm"
	${git} "${DIR}/patches/pwm/0001-pwm_backlight-Add-device-tree-support-for-Low-Thresh.patch"
	${git} "${DIR}/patches/pwm/0002-Control-module-EHRPWM-clk-enabling.patch"
	${git} "${DIR}/patches/pwm/0003-pwm-pwm_test-Driver-support-for-PWM-module-testing.patch"
	${git} "${DIR}/patches/pwm/0004-ARM-OMAP2-PWM-limit-am33xx_register_ehrpwm-to-soc_is.patch"
	${git} "${DIR}/patches/pwm/0005-pwm-export-of_pwm_request.patch"
	${git} "${DIR}/patches/pwm/0006-pwm-pwm-tiehrpwm-Update-the-clock-handling-of-pwm-ti.patch"
	${git} "${DIR}/patches/pwm/0007-ARM-AM33XX-clk-Add-clock-node-for-EHRPWM-TBCLK.patch"
	${git} "${DIR}/patches/pwm/0008-HACK-am33xx.dtsi-turn-on-all-PWMs.patch"
	${git} "${DIR}/patches/pwm/0009-pwm-add-sysfs-interface.patch"

	echo "dir: mmc"
	${git} "${DIR}/patches/mmc/0001-am33xx.dtsi-enable-MMC-HSPE-bit-for-all-3-controller.patch"
	${git} "${DIR}/patches/mmc/0002-omap-hsmmc-Correct-usage-of-of_find_node_by_name.patch"

	echo "dir: crypto"
	${git} "${DIR}/patches/crypto/0001-ARM-OMAP2xxx-hwmod-Convert-SHAM-crypto-device-data-t.patch"
	${git} "${DIR}/patches/crypto/0002-ARM-OMAP2xxx-hwmod-Add-DMA-support-for-SHAM-module.patch"
	${git} "${DIR}/patches/crypto/0003-ARM-OMAP3xxx-hwmod-Convert-SHAM-crypto-device-data-t.patch"
	${git} "${DIR}/patches/crypto/0004-ARM-OMAP2-Remove-unnecessary-message-when-no-SHA-IP-.patch"
	${git} "${DIR}/patches/crypto/0005-ARM-OMAP2-Only-manually-add-hwmod-data-when-DT-not-u.patch"
	${git} "${DIR}/patches/crypto/0006-ARM-AM33XX-Add-sha0-crypto-clock-data.patch"
	${git} "${DIR}/patches/crypto/0007-ARM-AM33XX-hwmod-Update-and-uncomment-SHA0-module-da.patch"
	${git} "${DIR}/patches/crypto/0008-ARM-dts-Add-SHAM-data-and-documentation-for-AM33XX.patch"
	${git} "${DIR}/patches/crypto/0009-ARM-OMAP2xxx-hwmod-Convert-AES-crypto-devcie-data-to.patch"
	${git} "${DIR}/patches/crypto/0010-ARM-OMAP3xxx-hwmod-Convert-AES-crypto-device-data-to.patch"
	${git} "${DIR}/patches/crypto/0011-ARM-OMAP2-Remove-unnecessary-message-when-no-AES-IP-.patch"
	${git} "${DIR}/patches/crypto/0012-ARM-OMAP2-Only-manually-add-hwmod-data-when-DT-not-u.patch"
	${git} "${DIR}/patches/crypto/0013-ARM-AM33XX-Add-aes0-crypto-clock-data.patch"
	${git} "${DIR}/patches/crypto/0014-ARM-AM33XX-hwmod-Update-and-uncomment-AES0-module-da.patch"
	${git} "${DIR}/patches/crypto/0015-ARM-dts-Add-AES-data-and-documentation-for-AM33XX.patch"
	${git} "${DIR}/patches/crypto/0016-crypto-omap-sham-Remove-unnecessary-pr_info-noise.patch"
	${git} "${DIR}/patches/crypto/0017-crypto-omap-sham-Convert-to-use-pm_runtime-API.patch"
	${git} "${DIR}/patches/crypto/0018-crypto-omap-sham-Add-suspend-resume-support.patch"
	${git} "${DIR}/patches/crypto/0019-crypto-omap-sham-Add-code-to-use-dmaengine-API.patch"
	${git} "${DIR}/patches/crypto/0020-crypto-omap-sham-Remove-usage-of-private-DMA-API.patch"
	${git} "${DIR}/patches/crypto/0021-crypto-omap-sham-Add-Device-Tree-Support.patch"
	${git} "${DIR}/patches/crypto/0022-crypto-omap-sham-Convert-to-dma_request_slave_channe.patch"
	${git} "${DIR}/patches/crypto/0023-crypto-omap-sham-Add-OMAP4-AM33XX-SHAM-Support.patch"
	${git} "${DIR}/patches/crypto/0024-crypto-omap-sham-Add-SHA224-and-SHA256-Support.patch"
	${git} "${DIR}/patches/crypto/0025-crypto-omap-aes-Remmove-unnecessary-pr_info-noise.patch"
	${git} "${DIR}/patches/crypto/0026-crypto-omap-aes-Don-t-reset-controller-for-every-ope.patch"
	${git} "${DIR}/patches/crypto/0027-crypto-omap-aes-Convert-to-use-pm_runtime-API.patch"
	${git} "${DIR}/patches/crypto/0028-crypto-omap-aes-Add-suspend-resume-support.patch"
	${git} "${DIR}/patches/crypto/0029-crypto-omap-aes-Add-code-to-use-dmaengine-API.patch"
	${git} "${DIR}/patches/crypto/0030-crypto-omap-aes-Remove-usage-of-private-DMA-API.patch"
	${git} "${DIR}/patches/crypto/0031-crypto-omap-aes-Add-Device-Tree-Support.patch"
	${git} "${DIR}/patches/crypto/0032-crypto-omap-aes-Convert-to-dma_request_slave_channel.patch"
	${git} "${DIR}/patches/crypto/0033-crypto-omap-aes-Add-OMAP4-AM33XX-AES-Support.patch"
	${git} "${DIR}/patches/crypto/0034-crypto-omap-aes-Add-CTR-algorithm-Support.patch"

	echo "dir: 6lowpan"
	${git} "${DIR}/patches/6lowpan/0001-6lowpan-Refactor-packet-delivery-into-a-function.patch"
	${git} "${DIR}/patches/6lowpan/0002-6lowpan-Handle-uncompressed-IPv6-packets-over-6LoWPA.patch"
	${git} "${DIR}/patches/6lowpan/0003-wpan-whitespace-fix.patch"
	${git} "${DIR}/patches/6lowpan/0004-6lowpan-use-stack-buffer-instead-of-heap.patch"
	${git} "${DIR}/patches/6lowpan/0005-wpan-use-stack-buffer-instead-of-heap.patch"
	${git} "${DIR}/patches/6lowpan/0006-mrf24j40-pinctrl-support.patch"
	${git} "${DIR}/patches/6lowpan/0007-mrf24j40-Warn-if-transmit-interrupts-timeout.patch"
	${git} "${DIR}/patches/6lowpan/0008-mrf24j40-Increase-max-SPI-speed-to-10MHz.patch"
	${git} "${DIR}/patches/6lowpan/0009-mrf24j40-Fix-byte-order-of-IEEE-address.patch"
	${git} "${DIR}/patches/6lowpan/0010-6lowpan-lowpan_is_iid_16_bit_compressable-does-not-d.patch"
	${git} "${DIR}/patches/6lowpan/0011-6lowpan-next-header-is-not-properly-set-upon-decompr.patch"
	${git} "${DIR}/patches/6lowpan/0012-6lowpan-always-enable-link-layer-acknowledgments.patch"
	${git} "${DIR}/patches/6lowpan/0013-mac802154-turn-on-ACK-when-enabled-by-the-upper-laye.patch"
	${git} "${DIR}/patches/6lowpan/0014-6lowpan-use-short-IEEE-802.15.4-addresses-for-broadc.patch"
	${git} "${DIR}/patches/6lowpan/0015-6lowpan-fix-first-fragment-FRAG1-handling.patch"
	${git} "${DIR}/patches/6lowpan/0016-6lowpan-add-debug-messages-for-6LoWPAN-fragmentation.patch"
	${git} "${DIR}/patches/6lowpan/0017-6lowpan-store-fragment-tag-values-per-device-instead.patch"
	${git} "${DIR}/patches/6lowpan/0018-mac802154-add-mac802154_dev_get_dsn.patch"
	${git} "${DIR}/patches/6lowpan/0019-6lowpan-obtain-IEEE802.15.4-sequence-number-from-the.patch"
	${git} "${DIR}/patches/6lowpan/0020-6lowpan-use-the-PANID-provided-by-the-device-instead.patch"
	${git} "${DIR}/patches/6lowpan/0021-6lowpan-modify-udp-compression-uncompression-to-matc.patch"
	${git} "${DIR}/patches/6lowpan/0022-6lowpan-fix-a-small-formatting-issue.patch"
	${git} "${DIR}/patches/6lowpan/0023-6lowpan-use-IEEE802154_ADDR_LEN-instead-of-a-magic-n.patch"

	echo "dir: capebus"
	${git} "${DIR}/patches/capebus/0001-gpio-keys-Pinctrl-fy.patch"
	${git} "${DIR}/patches/capebus/0002-tps65217-Allow-placement-elsewhere-than-parent-mfd-d.patch"
	${git} "${DIR}/patches/capebus/0003-pwm-backlight-Pinctrl-fy.patch"
	${git} "${DIR}/patches/capebus/0004-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	${git} "${DIR}/patches/capebus/0005-beaglebone-create-a-shared-dtsi-for-beaglebone-based.patch"
	${git} "${DIR}/patches/capebus/0006-beaglebone-enable-emmc-for-bonelt.patch"
	${git} "${DIR}/patches/capebus/0007-Fix-appended-dtb-rule.patch"
}

arm () {
	echo "dir: arm"
	${git} "${DIR}/patches/arm/0001-deb-pkg-Simplify-architecture-matching-for-cross-bui.patch"
	${git} "${DIR}/patches/arm/0002-Without-MACH_-option-Early-printk-DEBUG_LL.patch"
	${git} "${DIR}/patches/arm/0003-ARM-7668-1-fix-memset-related-crashes-caused-by-rece.patch"
	${git} "${DIR}/patches/arm/0004-ARM-7670-1-fix-the-memset-fix.patch"
	${git} "${DIR}/patches/arm/0005-ARM-DTS-AM33XX-Add-PMU-support.patch"
}

omap () {
	echo "dir: omap"

	#Fixes 800Mhz boot lockup: http://www.spinics.net/lists/linux-omap/msg83737.html
	${git} "${DIR}/patches/omap/0001-regulator-core-if-voltage-scaling-fails-restore-orig.patch"
	${git} "${DIR}/patches/omap/0002-omap2-twl-common-Add-default-power-configuration.patch"
	${git} "${DIR}/patches/omap/0003-omap2-irq-fix-interrupt-latency.patch"
	${git} "${DIR}/patches/omap/0003-mfd-omap-usb-host-Fix-clk-warnings-at-boot.patch"

	echo "dir: omap/sakoman"
	${git} "${DIR}/patches/omap_sakoman/0001-OMAP-DSS2-add-bootarg-for-selecting-svideo.patch"
	${git} "${DIR}/patches/omap_sakoman/0002-video-add-timings-for-hd720.patch"

	echo "dir: omap/beagle/expansion"
	${git} "${DIR}/patches/omap_beagle_expansion/0001-Beagle-expansion-add-buddy-param-for-expansionboard-.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0002-Beagle-expansion-add-zippy.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0003-Beagle-expansion-add-zippy2.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0004-Beagle-expansion-add-trainer.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0005-Beagle-expansion-add-CircuitCo-ulcd-Support.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0006-Beagle-expansion-add-wifi.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0007-Beagle-expansion-add-beaglefpga.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0008-Beagle-expansion-add-spidev.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0009-Beagle-expansion-add-Aptina-li5m03-camera.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0010-Beagle-expansion-add-LSR-COM6L-Adapter-Board.patch"
	${git} "${DIR}/patches/omap_beagle_expansion/0011-Beagle-expansion-LSR-COM6L-Adapter-Board-also-initia.patch"

	echo "dir: omap/beagle"
	#Status: for meego guys..
	${git} "${DIR}/patches/omap_beagle/0001-meego-modedb-add-Toshiba-LTA070B220F-800x480-support.patch"
	${git} "${DIR}/patches/omap_beagle/0002-backlight-Add-TLC59108-backlight-control-driver.patch"
	${git} "${DIR}/patches/omap_beagle/0003-tlc59108-adjust-for-beagleboard-uLCD7.patch"

	#Status: not for upstream
	${git} "${DIR}/patches/omap_beagle/0004-zeroMAP-Open-your-eyes.patch"

	${git} "${DIR}/patches/omap_beagle/0005-ARM-OMAP-Beagle-use-TWL4030-generic-reset-script.patch"

	echo "dir: omap/panda"
	#Status: not for upstream: push device tree version upstream...
	${git} "${DIR}/patches/omap_panda/0001-panda-fix-wl12xx-regulator.patch"
	#Status: unknown: cherry picked from linaro
	${git} "${DIR}/patches/omap_panda/0002-ti-st-st-kim-fixing-firmware-path.patch"
}

am33x_after () {
	echo "dir: net"
	${git} "${DIR}/patches/net/0001-am33xx-cpsw-default-to-ethernet-hwaddr-from-efuse-if.patch"
	${git} "${DIR}/patches/net/0002-Attempted-SMC911x-BQL-patch.patch"
	${git} "${DIR}/patches/net/0003-cpsw-Fix-interrupt-storm-among-other-things.patch"
	${git} "${DIR}/patches/net/0004-beaglebone-TT3201-MCP2515-fixes.patch"
	${git} "${DIR}/patches/net/0005-add-proper-db.txt-for-CRDA.patch"
	${git} "${DIR}/patches/net/0006-mcp251x-add-device-tree-support.patch"
	${git} "${DIR}/patches/net/0007-net-cpsw-fix-irq_disable-with-threaded-interrupts.patch"
	${git} "${DIR}/patches/net/0008-wireless-rtl8192cu-v4.0.2_9000.20130911.patch"
	${git} "${DIR}/patches/net/0009-cpsw-search-for-phy.patch"
	${git} "${DIR}/patches/net/0010-backport-patch-to-fix-kernel-panic-caused-by-c_can-driver.patch"

	echo "dir: drm"
	${git} "${DIR}/patches/drm/0001-am33xx-Add-clock-for-the-lcdc-DRM-driver.patch"
	${git} "${DIR}/patches/drm/0002-drm-small-fix-in-drm_send_vblank_event.patch"
	${git} "${DIR}/patches/drm/0003-drm-cma-add-debugfs-helpers.patch"
	${git} "${DIR}/patches/drm/0004-drm-i2c-encoder-helper-wrappers.patch"
	${git} "${DIR}/patches/drm/0005-drm-nouveau-use-i2c-encoder-helper-wrappers.patch"
	${git} "${DIR}/patches/drm/0006-drm-i2c-give-i2c-it-s-own-Kconfig.patch"
	${git} "${DIR}/patches/drm/0007-drm-tilcdc-add-TI-LCD-Controller-DRM-driver-v4.patch"
	${git} "${DIR}/patches/drm/0008-drm-i2c-nxp-tda998x-v3.patch"
	${git} "${DIR}/patches/drm/0009-drm-tilcdc-add-encoder-slave.patch"
	${git} "${DIR}/patches/drm/0010-drm-tilcdc-add-support-for-LCD-panels-v5.patch"
	${git} "${DIR}/patches/drm/0011-drm-lcdc-Power-control-GPIO-support.patch"
	${git} "${DIR}/patches/drm/0012-drm-tilcdc-Fix-scheduling-while-atomic-from-irq-hand.patch"

	echo "dir: not-capebus"
	${git} "${DIR}/patches/not-capebus/0001-add-dvi-pinmuxes-to-am33xx.dtsi.patch"
	${git} "${DIR}/patches/not-capebus/0002-add-defconfig-file-to-use-as-.config.patch"
	${git} "${DIR}/patches/not-capebus/0003-am33xx-musb-Add-OF-definitions.patch"
	${git} "${DIR}/patches/not-capebus/0004-Mark-the-device-as-PRIVATE.patch"
	${git} "${DIR}/patches/not-capebus/0005-omap_hsmmc-Bug-fixes-pinctl-gpio-reset.patch"
	${git} "${DIR}/patches/not-capebus/0006-tps65217-bl-Locate-backlight-node-correctly.patch"
	${git} "${DIR}/patches/not-capebus/0007-arm-Export-cache-flush-management-symbols-when-MULTI.patch"
	${git} "${DIR}/patches/not-capebus/0008-am335x-bone-dtsi-Clean-up.patch"
	${git} "${DIR}/patches/not-capebus/0009-am335x-bone-dtsi-Introduce-new-I2C-entries.patch"
	${git} "${DIR}/patches/not-capebus/0010-am335x-dt-Add-I2C0-pinctrl-entries.patch"
	${git} "${DIR}/patches/not-capebus/0011-Cleanup-am33xx.dtsi.patch"
	${git} "${DIR}/patches/not-capebus/0012-Fix-platform-device-resource-linking.patch"
	${git} "${DIR}/patches/not-capebus/0013-Link-platform-device-resources-properly.patch"
	${git} "${DIR}/patches/not-capebus/0014-Properly-handle-resources-for-omap_devices.patch"
	${git} "${DIR}/patches/not-capebus/0015-omap-Avoid-crashes-in-the-case-of-hwmod-misconfigura.patch"
	${git} "${DIR}/patches/not-capebus/0016-i2c-EEPROM-In-kernel-memory-accessor-interface.patch"
	${git} "${DIR}/patches/not-capebus/0017-Fix-util_is_printable_string.patch"
	${git} "${DIR}/patches/not-capebus/0018-fdtdump-properly-handle-multi-string-properties.patch"
	${git} "${DIR}/patches/not-capebus/0019-dtc-Dynamic-symbols-fixup-support.patch"
	${git} "${DIR}/patches/not-capebus/0020-dtc-Add-DTCO-rule-for-DTB-objects.patch"
	${git} "${DIR}/patches/not-capebus/0021-OF-Compile-Device-Tree-sources-with-resolve-option.patch"
	${git} "${DIR}/patches/not-capebus/0022-firmware-update-.gitignore-with-dtbo-objects.patch"
	${git} "${DIR}/patches/not-capebus/0023-OF-Introduce-device-tree-node-flag-helpers.patch"
	${git} "${DIR}/patches/not-capebus/0024-OF-export-of_property_notify.patch"
	${git} "${DIR}/patches/not-capebus/0025-OF-Export-all-DT-proc-update-functions.patch"
	${git} "${DIR}/patches/not-capebus/0026-OF-Introduce-utility-helper-functions.patch"
	${git} "${DIR}/patches/not-capebus/0027-OF-Introduce-Device-Tree-resolve-support.patch"
	${git} "${DIR}/patches/not-capebus/0028-OF-Introduce-DT-overlay-support.patch"
	${git} "${DIR}/patches/not-capebus/0029-capemgr-Capemgr-makefiles-and-Kconfig-fragments.patch"
	${git} "${DIR}/patches/not-capebus/0030-capemgr-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/not-capebus/0031-capemgr-Add-beaglebone-s-cape-driver-bindings.patch"
	${git} "${DIR}/patches/not-capebus/0032-capemgr-am33xx-family-DT-bindings.patch"
	${git} "${DIR}/patches/not-capebus/0033-bone-geiger-Geiger-bone-driver.patch"
	${git} "${DIR}/patches/not-capebus/0034-capemgr-firmware-makefiles-for-DT-objects.patch"
	${git} "${DIR}/patches/not-capebus/0035-capemgr-emmc2-cape-definition.patch"
	${git} "${DIR}/patches/not-capebus/0036-capemgr-DVI-capes-definitions.patch"
	${git} "${DIR}/patches/not-capebus/0037-capemgr-Geiger-cape-definition.patch"
	${git} "${DIR}/patches/not-capebus/0038-capemgr-LCD3-cape-definition.patch"
	${git} "${DIR}/patches/not-capebus/0039-capemgr-Add-weather-cape-definition.patch"
	${git} "${DIR}/patches/not-capebus/0040-ehrpwm-add-missing-dts-nodes.patch"
	${git} "${DIR}/patches/not-capebus/0041-am33xx-DT-Update-am33xx.dsi-with-the-new-PWM-DT-bind.patch"
	${git} "${DIR}/patches/not-capebus/0042-geiger-cape-Update-to-using-the-new-PWM-interface.patch"
	${git} "${DIR}/patches/not-capebus/0043-lcd3-cape-Change-into-using-the-lcdc-DRM-driver-inst.patch"
	${git} "${DIR}/patches/not-capebus/0044-am33xx-Add-default-config.patch"
	${git} "${DIR}/patches/not-capebus/0045-lcd3-cape-Convert-to-using-the-proper-touchscreen-dr.patch"
	${git} "${DIR}/patches/not-capebus/0046-geiger-cape-Convert-to-using-the-new-ADC-driver.patch"
	${git} "${DIR}/patches/not-capebus/0047-cape-dvi-Convert-DVI-capes-to-the-new-LCDC-DRM-drive.patch"
	${git} "${DIR}/patches/not-capebus/0048-boneblack-Add-default-HDMI-cape.patch"
	${git} "${DIR}/patches/not-capebus/0049-cape-bone-dvi-Use-720p-mode-as-default.patch"
	${git} "${DIR}/patches/not-capebus/0050-am33xx.dtsi-Make-the-MUSB-not-crash-on-load.patch"
	${git} "${DIR}/patches/not-capebus/0051-regulator-DUMMY_REGULATOR-should-work-for-OF-too.patch"
	${git} "${DIR}/patches/not-capebus/0052-OF-Overlay-Remove-excessive-debugging-crud.patch"
	${git} "${DIR}/patches/not-capebus/0053-of-i2c-Export-single-device-registration-method.patch"
	${git} "${DIR}/patches/not-capebus/0054-OF-Overlay-I2C-client-devices-special-handling.patch"
	${git} "${DIR}/patches/not-capebus/0055-omap-Fix-bug-on-partial-resource-addition.patch"
	${git} "${DIR}/patches/not-capebus/0056-ASoC-davinci-mcasp-Add-pinctrl-support.patch"
	${git} "${DIR}/patches/not-capebus/0057-ASoC-Davinci-machine-Add-device-tree-binding.patch"
	${git} "${DIR}/patches/not-capebus/0058-am33xx-Add-mcasp0-and-mcasp1-device-tree-entries.patch"
	${git} "${DIR}/patches/not-capebus/0059-ASoC-dts-OMAP2-AM33xx-HACK-Add-missing-dma-info.patch"
	${git} "${DIR}/patches/not-capebus/0060-ASoC-Davinci-McASP-remove-unused-header-include.patch"
	${git} "${DIR}/patches/not-capebus/0061-ASoC-AM33XX-Add-support-for-AM33xx-SoC-Audio.patch"
	${git} "${DIR}/patches/not-capebus/0062-am33xx-mcasp-Add-dma-channel-definitions.patch"
	${git} "${DIR}/patches/not-capebus/0063-ARM-OMAP2-AM33xx-removed-invalid-McASP-HWMOD-data.patch"
	${git} "${DIR}/patches/not-capebus/0064-davinci-evm-Header-include-move-fix.patch"
	${git} "${DIR}/patches/not-capebus/0065-bone-dvi-cape-Add-DT-definition-for-00A2-revision.patch"
	${git} "${DIR}/patches/not-capebus/0066-bone-dvi-cape-Update-A1-cape-definition-with-sound.patch"
	${git} "${DIR}/patches/not-capebus/0067-sndsoc-mcasp-Get-DMA-channels-via-byname.patch"
	${git} "${DIR}/patches/not-capebus/0068-sound-soc-Davinci-Remove-__devinit-__devexit.patch"
	${git} "${DIR}/patches/not-capebus/0069-st7735fb-Remove-__devinit-__devexit.patch"
	${git} "${DIR}/patches/not-capebus/0070-capemgr-Remove-__devinit-__devexit.patch"
	${git} "${DIR}/patches/not-capebus/0071-capes-fw-target-firmware-directory-change.patch"
	${git} "${DIR}/patches/not-capebus/0072-am33xx-edma-Always-update-unused-channel-list.patch"
	${git} "${DIR}/patches/not-capebus/0073-defconfig-Update-bone-default-config.patch"
	${git} "${DIR}/patches/not-capebus/0074-capes-add-dvi-a2-and-lcd3-a2-dts-files.patch"
	${git} "${DIR}/patches/not-capebus/0075-capemgr-catch-up-with-lcdc-tilcdc-rename.patch"
	${git} "${DIR}/patches/not-capebus/0076-firmware-fix-dvi-a1-target.patch"
	${git} "${DIR}/patches/not-capebus/0077-capes-remove-tda-from-hdmi-cape-lcdc-handles-it-by-t.patch"
	${git} "${DIR}/patches/not-capebus/0078-tilcdc-magic-debug-statement-makes-power-gpio-work-o.patch"
	${git} "${DIR}/patches/not-capebus/0079-capemgr-add-dts-overlay-for-LCD7-00A2-cape.patch"
	${git} "${DIR}/patches/not-capebus/0080-HACK-am33xx.dtsi-enable-all-PWMs.patch"
	${git} "${DIR}/patches/not-capebus/0081-beaglebone-Add-nixie-cape-prototype-driver.patch"
	${git} "${DIR}/patches/not-capebus/0082-beaglebone-Add-nixie-cape-device-tree-entry.patch"
	${git} "${DIR}/patches/not-capebus/0083-am335x-bone-common.dtsi-Cleanup-test-remnants.patch"
	${git} "${DIR}/patches/not-capebus/0084-omap_hsmmc-Add-ti-vcc-aux-disable-is-sleep-DT-proper.patch"
	${git} "${DIR}/patches/not-capebus/0085-bone-common-ti-vcc-aux-disable-is-sleep-enable.patch"
	${git} "${DIR}/patches/not-capebus/0086-am33xx-disable-NAPI.patch"
	${git} "${DIR}/patches/not-capebus/0087-capemgr-Fixed-AIN-name-display-in-error-message.patch"
	${git} "${DIR}/patches/not-capebus/0088-am33xx.dtsi-remove-duplicate-nodes.patch"
	${git} "${DIR}/patches/not-capebus/0089-cape-dtbos-update-to-latest-OF-videomode-bindings.patch"
	${git} "${DIR}/patches/not-capebus/0090-beaglebone-uncomment-eMMC-override.patch"
	${git} "${DIR}/patches/not-capebus/0091-bone-capes-Update-with-new-tscadc-bindings.patch"
	${git} "${DIR}/patches/not-capebus/0092-am33xx.dtsi-Update-and-disable-status-of-nodes.patch"
	${git} "${DIR}/patches/not-capebus/0093-bone-capes-Adapt-to-new-pwms-setup.patch"
	${git} "${DIR}/patches/not-capebus/0094-tilcdc-introduce-panel-tfp410-power-down-gpio-contro.patch"
	${git} "${DIR}/patches/not-capebus/0095-bone-dvi-Update-to-new-style-tilcdc-bindings.patch"
	${git} "${DIR}/patches/not-capebus/0096-tilcdc-tfp410-Rework-power-down-GPIO-logic.patch"
	${git} "${DIR}/patches/not-capebus/0097-tilcdc-Add-reduced-blanking-mode-checks.patch"
	${git} "${DIR}/patches/not-capebus/0098-cape-dvi-Switch-all-DVI-capes-to-using-the-TFTP410-p.patch"
	${git} "${DIR}/patches/not-capebus/0099-beaglebone-switch-eMMC-to-8bit-mode.patch"
	${git} "${DIR}/patches/not-capebus/0100-Pinmux-helper-driver.patch"
	${git} "${DIR}/patches/not-capebus/0101-OF-Clear-detach-flag-on-attach.patch"
	${git} "${DIR}/patches/not-capebus/0102-OF-overlay-Fix-overlay-revert-failure.patch"
	${git} "${DIR}/patches/not-capebus/0103-bone-capemgr-Make-sure-cape-removal-works.patch"
	${git} "${DIR}/patches/not-capebus/0104-bone-capemgr-Fix-crash-when-trying-to-remove-non-exi.patch"
	${git} "${DIR}/patches/not-capebus/0105-beaglebone-LCD7-cape-enable-PWM-and-allow-the-specif.patch"
	${git} "${DIR}/patches/not-capebus/0106-bone-capemgr-Introduce-pinmux-helper.patch"
	${git} "${DIR}/patches/not-capebus/0107-bone-geiger-Fix-comment-to-match-the-contents.patch"
	${git} "${DIR}/patches/not-capebus/0108-of-overlay-Handle-I2C-devices-already-registered-by-.patch"
	${git} "${DIR}/patches/not-capebus/0109-pinmux-helper-Add-runtime-configuration-capability.patch"
	${git} "${DIR}/patches/not-capebus/0110-pinmux-helper-Switch-to-using-kmalloc.patch"
	${git} "${DIR}/patches/not-capebus/0111-i2c-DTify-pca954x-driver.patch"
	${git} "${DIR}/patches/not-capebus/0112-tty-Add-JHD629-I2C-LCD-Keypad-TTY-driver.patch"
	${git} "${DIR}/patches/not-capebus/0113-grove-i2c-Add-rudimentary-grove-i2c-motor-control-dr.patch"
	${git} "${DIR}/patches/not-capebus/0114-tty-jhd629-i2c-Clean-keypad-buffer-when-starting.patch"
	${git} "${DIR}/patches/not-capebus/0115-am335x-bone-common-Remove-SPI-unused-pinmux-config.patch"
	${git} "${DIR}/patches/not-capebus/0116-bone-capemgr-Force-a-slot-to-load-unconditionally.patch"
	${git} "${DIR}/patches/not-capebus/0117-beaglebone-Added-Adafruit-prototype-cape.patch"
	${git} "${DIR}/patches/not-capebus/0118-tilcdc-Enable-reduced-blanking-check-only-on-DVI-sla.patch"
	${git} "${DIR}/patches/not-capebus/0119-cape-adafruit-Use-the-correct-spi-bus-spi1-no-spi0.patch"
	${git} "${DIR}/patches/not-capebus/0120-BBB-tester-Introduce-board-DTS.patch"
	${git} "${DIR}/patches/not-capebus/0121-BBB-tester-Introduce-cape-describing-the-contents-of.patch"
	${git} "${DIR}/patches/not-capebus/0122-bone-tester-Add-overrides-for-BB-BONE-TESTER.patch"
	${git} "${DIR}/patches/not-capebus/0123-cape-tester-Add-uart-specific-default-pinmux-state.patch"
	${git} "${DIR}/patches/not-capebus/0124-cape-tester-Add-pinmux-helper-for-drvvbus-gpio.patch"
	${git} "${DIR}/patches/not-capebus/0125-cape-Added-support-for-IIO-helper-cape.patch"
	${git} "${DIR}/patches/not-capebus/0126-cape-Added-example-IIO-tester-dynamics-overlay.patch"
	${git} "${DIR}/patches/not-capebus/0127-docs-Added-capemanager-extra_override-usage.patch"
	${git} "${DIR}/patches/not-capebus/0128-capemgr-Added-module-param-descriptions.patch"
	${git} "${DIR}/patches/not-capebus/0129-beaglebone-Add-Adafruit-RTC-prototype-cape.patch"
	${git} "${DIR}/patches/not-capebus/0130-cape-vsense-scale-division-by-zero-check.patch"
	${git} "${DIR}/patches/not-capebus/0131-capes-add-cape-for-beaglebone-based-Hexy-robot.patch"
	${git} "${DIR}/patches/not-capebus/0132-Extend-bone-iio-helper.patch"
	${git} "${DIR}/patches/not-capebus/0133-Update-iio-helper-with-more-channels.patch"
	${git} "${DIR}/patches/not-capebus/0134-Add-ADC-IIO-helper.patch"
	${git} "${DIR}/patches/not-capebus/0135-Changing-DT-data-to-make-selection-of-standard-i.e.-.patch"
	${git} "${DIR}/patches/not-capebus/0136-Enhancing-to-support-extra-device-tree-options-for-t.patch"
	${git} "${DIR}/patches/not-capebus/0137-add-WIP-support-LCD4-rev-00A4.patch"
	${git} "${DIR}/patches/not-capebus/0138-add-eMMC-cape-support.patch"
	${git} "${DIR}/patches/not-capebus/0139-Remove-UART-pins-from-the-expansion-set.patch"
	${git} "${DIR}/patches/not-capebus/0140-Remove-LCD-pins-from-the-expansion-test-part.patch"
	${git} "${DIR}/patches/not-capebus/0141-Remove-I2C2-pins-from-expansion-test.patch"
	${git} "${DIR}/patches/not-capebus/0142-Add-expansion-test-cape-fragment.patch"
	${git} "${DIR}/patches/not-capebus/0143-tilcdc-added-some-extra-debug-and-softened-the-wordi.patch"
	${git} "${DIR}/patches/not-capebus/0144-Make-sure-various-timings-fit-within-the-bits-availa.patch"
	${git} "${DIR}/patches/not-capebus/0145-fix-cape-bone-hexy.patch"
	${git} "${DIR}/patches/not-capebus/0146-firmware-DT-Fragment-for-MRF24J40-BeagleBone-Cape.patch"
	${git} "${DIR}/patches/not-capebus/0147-firmware-capes-Update-MRF24J40-cape-to-work-with-lat.patch"
	${git} "${DIR}/patches/not-capebus/0148-am335x-bone-common-DT-Override-for-MRF24J40-Cape.patch"
	${git} "${DIR}/patches/not-capebus/0149-beaglebone-black-limit-LDO3-to-1.8V.patch"
	${git} "${DIR}/patches/not-capebus/0150-beaglebone-black-add-new-fixed-regulator-for-uSD-eMM.patch"
	${git} "${DIR}/patches/not-capebus/0151-capemgr-Implement-disable-overrides-on-the-cmd-line.patch"
	${git} "${DIR}/patches/not-capebus/0152-tilcdc-Enable-pinmux-states.patch"
	${git} "${DIR}/patches/not-capebus/0153-cape-Add-a-simple-cape-for-handling-the-uSD-button.patch"
	${git} "${DIR}/patches/not-capebus/0154-beaglebone-add-support-for-DVI-00A3.patch"
	${git} "${DIR}/patches/not-capebus/0155-beaglebone-remove-audio-section-from-DVID-rev-2-and-.patch"
	${git} "${DIR}/patches/not-capebus/0156-beaglebone-add-dts-for-audio-cape.patch"
	${git} "${DIR}/patches/not-capebus/0157-cape-bone-hexy-add-iio-helper.patch"
	${git} "${DIR}/patches/not-capebus/0158-cape-Add-CAPE-BONE-EXPTEST-to-capemaps.patch"
	${git} "${DIR}/patches/not-capebus/0159-tester-button-cape.patch"
	${git} "${DIR}/patches/not-capebus/0160-pwm_test-fix-some-issues.patch"
	${git} "${DIR}/patches/not-capebus/0161-pwm_test-Clean-up-and-make-it-work-on-DT-correctly.patch"
	${git} "${DIR}/patches/not-capebus/0162-capes-Add-PWM-test-example-cape.patch"
	${git} "${DIR}/patches/not-capebus/0163-Sync-tester-DTS-with-am335x-common.patch"
	${git} "${DIR}/patches/not-capebus/0164-Add-in-missing-cape-bone-tester-back-in.patch"
	${git} "${DIR}/patches/not-capebus/0165-cape-bone-hexy-move-OLED-to-different-reset-gpio.patch"
	${git} "${DIR}/patches/not-capebus/0166-firmware-capes-added-dts-file-for-every-PWM-pin.patch"
	${git} "${DIR}/patches/not-capebus/0167-capes-add-LCD7-A3.patch"
	${git} "${DIR}/patches/not-capebus/0168-capes-add-basic-support-for-LCD4-capes.patch"
	${git} "${DIR}/patches/not-capebus/0169-OF-overlay-Add-depth-option-for-device-creation.patch"
	${git} "${DIR}/patches/not-capebus/0170-capes-Add-BB-BONE-GPEVT-cape.patch"
	${git} "${DIR}/patches/not-capebus/0171-clock-Export-__clock_set_parent.patch"
	${git} "${DIR}/patches/not-capebus/0172-omap-clk-Add-adjustable-clkout2.patch"
	${git} "${DIR}/patches/not-capebus/0173-am33xx-Update-DTS-EDMA.patch"
	${git} "${DIR}/patches/not-capebus/0174-bone-Added-RS232-prototype-cape-DT-object.patch"
	${git} "${DIR}/patches/not-capebus/0175-Add-support-for-BB-BONE_SERL-01-00A1-CanBus-cape.patch"
	${git} "${DIR}/patches/not-capebus/0176-capes-Add-virtual-capes-serving-as-examples.patch"
	${git} "${DIR}/patches/not-capebus/0177-capes-Add-TowerTech-TT3201-CAN-Bus-Cape-TT3201-001-3.patch"
	${git} "${DIR}/patches/not-capebus/0178-capes-Add-commented-out-example-of-use-of-spi1_cs1.patch"
	${git} "${DIR}/patches/not-capebus/0179-cape-LCD4-Correct-key-active-polarity.patch"
	${git} "${DIR}/patches/not-capebus/0180-capes-lcd3-Correct-button-polarity.patch"
	${git} "${DIR}/patches/not-capebus/0181-cape-Fix-LCD7-keys-polarity.patch"
	${git} "${DIR}/patches/not-capebus/0182-gpio-Introduce-GPIO-OF-helper.patch"
	${git} "${DIR}/patches/not-capebus/0183-capes-ADC-GPIO-helper-capes.patch"
	${git} "${DIR}/patches/not-capebus/0184-capes-RS232-Cape-support-added.patch"

	echo "dir: pru"
	#Note verify: firmware/Makefile
	#	BB-BONE-PRU-01-00A0.dtbo \
	#	BB-BONE-PRU-02-00A0.dtbo \
	${git} "${DIR}/patches/pru/0001-uio-uio_pruss-port-to-AM33xx.patch"
	${git} "${DIR}/patches/pru/0002-ARM-omap-add-DT-support-for-deasserting-hardware-res.patch"
	${git} "${DIR}/patches/pru/0003-ARM-dts-AM33xx-PRUSS-support.patch"
	${git} "${DIR}/patches/pru/0004-uio_pruss-add-dt-support-replicape-00A1.patch"
	${git} "${DIR}/patches/pru/0005-pruss-Make-sure-it-works-when-no-child-nodes-are-pre.patch"
	${git} "${DIR}/patches/pru/0006-am33xx-pru-Very-simple-led-cape-via-GPO-of-the-PRU.patch"
	${git} "${DIR}/patches/pru/0007-PRU-remote-proc-wip.patch"
	${git} "${DIR}/patches/pru/0008-Add-sysfs-entry-for-DDR-sync.patch"
	${git} "${DIR}/patches/pru/0009-virtio-ring-Introduce-dma-mapping-for-real-devices.patch"
	${git} "${DIR}/patches/pru/0010-virtio_console-Simplify-virtio_console-for-h-w-devic.patch"
	${git} "${DIR}/patches/pru/0011-rpmsg-Make-the-buffers-number-and-size-configurable.patch"
	${git} "${DIR}/patches/pru/0012-remoteproc-Use-driver-ops-for-allocation-of-virtqueu.patch"
	${git} "${DIR}/patches/pru/0013-rproc-core-Allow-bootup-without-resources.patch"
	${git} "${DIR}/patches/pru/0014-tools-virtio-fix-build-for-3.8.patch"
	${git} "${DIR}/patches/pru/0015-rproc-pru-PRU-remoteproc-updated-to-work-with-virtio.patch"
	${git} "${DIR}/patches/pru/0016-capes-pru-Update-with-PRU-03-PRU-04.patch"
	${git} "${DIR}/patches/pru/0017-rproc-PRU-Add-downcall-RPC-capability.patch"
	${git} "${DIR}/patches/pru/0018-rproc-pru-Implement-a-software-defined-PWM-channel-s.patch"
	${git} "${DIR}/patches/pru/0019-capes-PRU-PWM-channels-information.patch"
	${git} "${DIR}/patches/pru/0020-PRU-2.0.0-compiler-changes-for-pru_rpoc.patch"

	echo "dir: usb"
	${git} "${DIR}/patches/usb/0001-drivers-usb-phy-add-a-new-driver-for-usb-part-of-con.patch"
	${git} "${DIR}/patches/usb/0002-drivers-usb-start-using-the-control-module-driver.patch"
	${git} "${DIR}/patches/usb/0003-usb-otg-Add-an-API-to-bind-the-USB-controller-and-PH.patch"
	${git} "${DIR}/patches/usb/0004-usb-otg-utils-add-facilities-in-phy-lib-to-support-m.patch"
	${git} "${DIR}/patches/usb/0005-ARM-OMAP-USB-Add-phy-binding-information.patch"
	${git} "${DIR}/patches/usb/0006-drivers-usb-musb-omap-make-use-of-the-new-PHY-lib-AP.patch"
	${git} "${DIR}/patches/usb/0007-usb-otg-add-device-tree-support-to-otg-library.patch"
	${git} "${DIR}/patches/usb/0008-USB-MUSB-OMAP-get-PHY-by-phandle-for-dt-boot.patch"
	${git} "${DIR}/patches/usb/0009-MUSB-Hack-around-to-make-host-port-to-work.patch"
	${git} "${DIR}/patches/usb/0010-make-sure-we-register-unregister-the-NOP-xceiver-onl.patch"
	${git} "${DIR}/patches/usb/0011-ARM-OMAP-am335x-musb-use-250-for-power.patch"
	${git} "${DIR}/patches/usb/0012-ARM-OMAP2-MUSB-Specify-omap4-has-mailbox.patch"
	${git} "${DIR}/patches/usb/0013-usb-musb-avoid-stopping-the-session-in-host-mode.patch"
	${git} "${DIR}/patches/usb/0014-usb-phy-introduce-set_vbus-method.patch"
	${git} "${DIR}/patches/usb/0015-usb-musb-core-Fix-remote-wakeup-resume.patch"
	${git} "${DIR}/patches/usb/0016-usb-musb-add-reset-hook-to-platform-ops.patch"
	${git} "${DIR}/patches/usb/0017-usb-musb-add-a-work_struct-to-recover-from-babble-er.patch"
	${git} "${DIR}/patches/usb/0018-usb-musb-dsps-handle-babble-interrupts.patch"
	${git} "${DIR}/patches/usb/0019-usb-musb-dsps-Call-usb_phy-_shutdown-_init-during-mu.patch"
	${git} "${DIR}/patches/usb/0020-usb-musb-core-Handle-Babble-condition-only-in-HOST-m.patch"
	${git} "${DIR}/patches/usb/0021-usb-musb-core-Convert-babble-recover-work-to-delayed.patch"
	${git} "${DIR}/patches/usb/0022-usb-musb-core-Convert-the-musb_platform_reset-to-hav.patch"

	echo "dir: PG2"
	${git} "${DIR}/patches/PG2/0001-beaglebone-black-1ghz-hack.patch"

	echo "dir: reboot"
	${git} "${DIR}/patches/reboot/0001-ARM-AM33xx-Add-SoC-specific-restart-hook.patch"

	echo "dir: iio"
	${git} "${DIR}/patches/iio/0001-iio-common-Add-STMicroelectronics-common-library.patch"
	${git} "${DIR}/patches/iio/0002-iio-accel-Add-STMicroelectronics-accelerometers-driv.patch"
	${git} "${DIR}/patches/iio/0003-iio-gyro-Add-STMicroelectronics-gyroscopes-driver.patch"
	${git} "${DIR}/patches/iio/0004-iio-magnetometer-Add-STMicroelectronics-magnetometer.patch"
	${git} "${DIR}/patches/iio/0005-iio-magn-Add-sensors_supported-in-st_magn_sensors.patch"
	${git} "${DIR}/patches/iio/0006-Invensense-MPU6050-Device-Driver.patch"
	${git} "${DIR}/patches/iio/0007-iio-imu-inv_mpu6050-depends-on-IIO_BUFFER.patch"
	${git} "${DIR}/patches/iio/0008-using-kfifo_in_spinlocked-instead-of-separate-code.patch"
	${git} "${DIR}/patches/iio/0009-pwm-add-pca9685-driver.patch"
	${git} "${DIR}/patches/iio/0010-pwm-Fill-in-missing-.owner-fields.patch"
	${git} "${DIR}/patches/iio/0011-pwm-pca9685-Fix-wrong-argument-to-set-MODE1_SLEEP-bi.patch"

	echo "dir: w1"
	${git} "${DIR}/patches/w1/0001-W1-w1-gpio-switch-to-using-dev_pm_ops.patch"
	${git} "${DIR}/patches/w1/0002-W1-w1-gpio-guard-DT-IDs-with-CONFIG_OF.patch"
	${git} "${DIR}/patches/w1/0003-W1-w1-gpio-rework-handling-of-platform-data.patch"
	${git} "${DIR}/patches/w1/0004-W1-w1-gpio-switch-to-using-managed-resources-devm.patch"

	echo "dir: gpmc"
	${git} "${DIR}/patches/gpmc/0001-ARM-OMAP-Clear-GPMC-bits-when-applying-new-setting.patch"
	${git} "${DIR}/patches/gpmc/0002-ARM-omap2-gpmc-Mark-local-scoped-functions-static.patch"
	${git} "${DIR}/patches/gpmc/0003-ARM-omap2-gpmc-Remove-unused-gpmc_round_ns_to_ticks-.patch"
	${git} "${DIR}/patches/gpmc/0004-ARM-omap2-gpmc-Fix-gpmc_cs_reserved-return-value.patch"
	${git} "${DIR}/patches/gpmc/0005-ARM-omap2-gpmc-nand-Print-something-useful-on-CS-req.patch"
	${git} "${DIR}/patches/gpmc/0006-ARM-omap2-gpmc-onenand-Print-something-useful-on-CS-.patch"
	${git} "${DIR}/patches/gpmc/0007-ARM-omap2-gpmc-onenand-Replace-pr_err-with-dev_err.patch"
	${git} "${DIR}/patches/gpmc/0008-ARM-omap2-gpmc-onenand-Replace-printk-KERN_ERR-with-.patch"
	${git} "${DIR}/patches/gpmc/0009-ARM-omap2-gpmc-Remove-redundant-chip-select-out-of-r.patch"
	${git} "${DIR}/patches/gpmc/0010-ARM-OMAP2-Simplify-code-configuring-ONENAND-devices.patch"
	${git} "${DIR}/patches/gpmc/0011-ARM-OMAP2-Add-variable-to-store-number-of-GPMC-waitp.patch"
	${git} "${DIR}/patches/gpmc/0012-ARM-OMAP2-Add-structure-for-storing-GPMC-settings.patch"
	${git} "${DIR}/patches/gpmc/0013-ARM-OMAP2-Add-function-for-configuring-GPMC-settings.patch"
	${git} "${DIR}/patches/gpmc/0014-ARM-OMAP2-Convert-ONENAND-to-use-gpmc_cs_program_set.patch"
	${git} "${DIR}/patches/gpmc/0015-ARM-OMAP2-Convert-NAND-to-use-gpmc_cs_program_settin.patch"
	${git} "${DIR}/patches/gpmc/0016-ARM-OMAP2-Convert-SMC91x-to-use-gpmc_cs_program_sett.patch"
	${git} "${DIR}/patches/gpmc/0017-ARM-OMAP2-Convert-TUSB-to-use-gpmc_cs_program_settin.patch"
	${git} "${DIR}/patches/gpmc/0018-ARM-OMAP2-Don-t-configure-of-chip-select-options-in-.patch"
	${git} "${DIR}/patches/gpmc/0019-ARM-OMAP2-Add-function-to-read-GPMC-settings-from-de.patch"
	${git} "${DIR}/patches/gpmc/0020-ARM-OMAP2-Add-additional-GPMC-timing-parameters.patch"
	${git} "${DIR}/patches/gpmc/0021-ARM-OMAP2-Add-device-tree-support-for-NOR-flash.patch"
	${git} "${DIR}/patches/gpmc/0022-ARM-OMAP2-Convert-NAND-to-retrieve-GPMC-settings-fro.patch"
	${git} "${DIR}/patches/gpmc/0023-ARM-OMAP2-Convert-ONENAND-to-retrieve-GPMC-settings-.patch"
	${git} "${DIR}/patches/gpmc/0024-ARM-OMAP2-Detect-incorrectly-aligned-GPMC-base-addre.patch"
	${git} "${DIR}/patches/gpmc/0025-ARM-OMAP2-Remove-unnecesssary-GPMC-definitions-and-v.patch"
	${git} "${DIR}/patches/gpmc/0026-ARM-OMAP2-Allow-GPMC-probe-to-complete-even-if-CS-ma.patch"
	${git} "${DIR}/patches/gpmc/0027-ARM-OMAP2-return-ENODEV-if-GPMC-child-device-creatio.patch"
	${git} "${DIR}/patches/gpmc/0028-ARM-OMAP2-rename-gpmc_probe_nor_child-to-gpmc_probe_.patch"
	${git} "${DIR}/patches/gpmc/0029-ARM-OMAP2-Add-GPMC-DT-support-for-Ethernet-child-nod.patch"
	${git} "${DIR}/patches/gpmc/0030-mtd-omap-nand-pass-device_node-in-platform-data.patch"
	${git} "${DIR}/patches/gpmc/0031-ARM-OMAP-gpmc-nand-drop-__init-annotation.patch"
	${git} "${DIR}/patches/gpmc/0032-ARM-OMAP-gpmc-enable-hwecc-for-AM33xx-SoCs.patch"
	${git} "${DIR}/patches/gpmc/0033-ARM-OMAP-gpmc-don-t-create-devices-from-initcall-on-.patch"
	${git} "${DIR}/patches/gpmc/0034-ARM-OMAP2-gpmc-onenand-drop-__init-annotation.patch"
	${git} "${DIR}/patches/gpmc/0035-gpmc-Add-missing-gpmc-includes.patch"
	${git} "${DIR}/patches/gpmc/0036-mtd-omap-onenand-pass-device_node-in-platform-data.patch"
	${git} "${DIR}/patches/gpmc/0037-ARM-OMAP2-Convert-ONENAND-to-use-gpmc_cs_program_set.patch"
	${git} "${DIR}/patches/gpmc/0038-omap-gpmc-Various-driver-fixes.patch"
	${git} "${DIR}/patches/gpmc/0039-gpmc-Add-DT-node-for-gpmc-on-am33xx.patch"

	echo "dir: mxt"
	${git} "${DIR}/patches/mxt/0001-CHROMIUM-Input-atmel_mxt_ts-refactor-i2c-error-handl.patch"
	${git} "${DIR}/patches/mxt/0002-CHROMIUM-Input-atmel_mxt_ts-register-input-device-be.patch"
	${git} "${DIR}/patches/mxt/0003-CHROMIUM-Input-atmel_mxt_ts-refactor-input-device-cr.patch"
	${git} "${DIR}/patches/mxt/0004-CHROMIUM-Input-atmel_mxt_ts-handle-bootloader-mode-a.patch"
	${git} "${DIR}/patches/mxt/0005-CHROMIUM-Input-atmel_mxt_ts-handle-errors-during-fw-.patch"
	${git} "${DIR}/patches/mxt/0006-CHROMIUM-Input-atmel_mxt_ts-destroy-state-before-fw-.patch"
	${git} "${DIR}/patches/mxt/0007-CHROMIUM-Input-atmel_mxt_ts-refactor-bootloader-entr.patch"
	${git} "${DIR}/patches/mxt/0008-CHROMIUM-Input-atmel_mxt_ts-wait-for-CHG-assert-in-m.patch"
	${git} "${DIR}/patches/mxt/0009-CHROMIUM-Input-atmel_mxt_ts-wait-for-CHG-after-bootl.patch"
	${git} "${DIR}/patches/mxt/0010-CHROMIUM-Input-atmel_mxt_ts-change-MXT_BOOT_LOW-to-0.patch"
	${git} "${DIR}/patches/mxt/0011-CHROMIUM-Input-atmel_mxt_ts-Increase-FWRESET_TIME.patch"
	${git} "${DIR}/patches/mxt/0012-CHROMIUM-Input-atmel_mxt_ts-add-calibrate-sysfs-entr.patch"
	${git} "${DIR}/patches/mxt/0013-CHROMIUM-Input-atmel_mxt_ts-add-sysfs-entry-to-read-.patch"
	${git} "${DIR}/patches/mxt/0014-CHROMIUM-Input-atmel_mxt_ts-add-sysfs-entry-to-read-.patch"
	${git} "${DIR}/patches/mxt/0015-CHROMIUM-Input-atmel_mxt_ts-verify-info-block-checks.patch"
	${git} "${DIR}/patches/mxt/0016-CHROMIUM-Input-atmel_mxt_tx-add-matrix_size-sysfs-en.patch"
	${git} "${DIR}/patches/mxt/0017-CHROMIUM-Input-atmel_mxt_ts-define-helper-functions-.patch"
	${git} "${DIR}/patches/mxt/0018-CHROMIUM-Input-atmel_mxt_ts-add-debugfs-infrastructu.patch"
	${git} "${DIR}/patches/mxt/0019-CHROMIUM-Input-atmel_mxt_ts-add-deltas-and-refs-debu.patch"
	${git} "${DIR}/patches/mxt/0020-CHROMIUM-Input-atmel_mxt_ts-add-device-id-for-touchp.patch"
	${git} "${DIR}/patches/mxt/0021-CHROMIUM-Input-atmel_mxt_ts-Read-resolution-from-dev.patch"
	${git} "${DIR}/patches/mxt/0022-CHROMIUM-Input-atmel_mxt_ts-Report-TOUCH-MAJOR-in-te.patch"
	${git} "${DIR}/patches/mxt/0023-CHROMIUM-Input-atmel_mxt_ts-add-new-object-types.patch"
	${git} "${DIR}/patches/mxt/0024-CHROMIUM-INPUT-atmel_mxt_ts-Increase-the-wait-times-.patch"
	${git} "${DIR}/patches/mxt/0025-CHROMIUM-Input-atmel_mxt_ts-dump-mxt_read-write_reg.patch"
	${git} "${DIR}/patches/mxt/0026-CHROMIUM-Input-atmel_mxt_ts-take-an-instance-for-mxt.patch"
	${git} "${DIR}/patches/mxt/0027-CHROMIUM-Input-atmel_mxt_ts-allow-writing-to-object-.patch"
	${git} "${DIR}/patches/mxt/0028-CHROMIUM-Input-atmel_mxt_ts-add-backupnv-sysfs-entry.patch"
	${git} "${DIR}/patches/mxt/0029-CHROMIUM-Input-atmel_mxt_ts-read-num-messages-then-a.patch"
	${git} "${DIR}/patches/mxt/0030-CHROMIUM-Input-atmel_mxt_ts-remove-mxt_make_highchg.patch"
	${git} "${DIR}/patches/mxt/0031-CHROMIUM-Input-atmel_mxt_ts-Remove-matrix-size-updat.patch"
	${git} "${DIR}/patches/mxt/0032-CHROMIUM-Input-atmel_mxt_ts-parse-vector-field-of-da.patch"
	${git} "${DIR}/patches/mxt/0033-CHROMIUM-Input-atmel_mxt_ts-Add-IDLE-DEEP-SLEEP-mode.patch"
	${git} "${DIR}/patches/mxt/0034-CHROMIUM-Input-atmel_mxt_ts-Move-object-from-sysfs-t.patch"
	${git} "${DIR}/patches/mxt/0035-CHROMIUM-Input-atmel_mxt_ts-Set-default-irqflags-whe.patch"
	${git} "${DIR}/patches/mxt/0036-CHROMIUM-Input-atmel_mxt_ts-Support-the-case-with-no.patch"
	${git} "${DIR}/patches/mxt/0037-CHROMIUM-Input-atmel_mxt_ts-Wait-on-auto-calibration.patch"
	${git} "${DIR}/patches/mxt/0038-CHROMIUM-Input-atmel_mxt_ts-Add-sysfs-entry-for-r-w-.patch"
	${git} "${DIR}/patches/mxt/0039-CHROMIUM-Input-atmel_mxt_ts-Add-sysfs-entry-for-r-w-.patch"
	${git} "${DIR}/patches/mxt/0040-CHROMIUM-Input-atmel_mxt_ts-add-sysfs-entry-for-writ.patch"
	${git} "${DIR}/patches/mxt/0041-CHROMIUM-Input-atmel_mxt_ts-make-mxt_initialize-asyn.patch"
	${git} "${DIR}/patches/mxt/0042-CHROMIUM-Input-atmel_mxt_ts-move-backup_nv-to-handle.patch"
	${git} "${DIR}/patches/mxt/0043-CHROMIUM-Input-atmel_mxt_ts-Add-defines-for-T9-Touch.patch"
	${git} "${DIR}/patches/mxt/0044-CHROMIUM-Input-atmel_mxt_ts-disable-reporting-on-sto.patch"
	${git} "${DIR}/patches/mxt/0045-CHROMIUM-Input-atmel_mxt_ts-Suppress-handle-messages.patch"
	${git} "${DIR}/patches/mxt/0046-CHROMIUM-Input-atmel_mxt_ts-save-and-restore-t9_ctrl.patch"
	${git} "${DIR}/patches/mxt/0047-CHROMIUM-Input-atmel_mxt_ts-enable-RPTEN-if-can-wake.patch"
	${git} "${DIR}/patches/mxt/0048-CHROMIUM-Input-atmel_mxt_ts-release-all-fingers-on-r.patch"
	${git} "${DIR}/patches/mxt/0049-CHROMIUM-Input-atmel_mxt_ts-make-suspend-power-acqui.patch"
	${git} "${DIR}/patches/mxt/0050-CHROMIUM-Input-atmel_mxt_ts-recalibrate-on-system-re.patch"
	${git} "${DIR}/patches/mxt/0051-CHROMIUM-Input-atmel_mxt_ts-Use-correct-max-touch_ma.patch"
	${git} "${DIR}/patches/mxt/0052-CHROMIUM-Input-atmel_mxt_ts-Add-support-for-T65-Lens.patch"
	${git} "${DIR}/patches/mxt/0053-CHROMIUM-Input-atmel_mxt_ts-On-Tpads-enable-T42-disa.patch"
	${git} "${DIR}/patches/mxt/0054-CHROMIUM-Input-atmel_mxt_ts-Set-power-wakeup-to-disa.patch"
	${git} "${DIR}/patches/mxt/0055-CHROMIUM-Input-atmel_mxt_ts-mxt_stop-on-lid-close.patch"
	${git} "${DIR}/patches/mxt/0056-CHROMIUM-Input-atmel_mxt_ts-Disable-T9-on-mxt_stop.patch"
	${git} "${DIR}/patches/mxt/0057-CHROMIUM-Input-atmel_mxt_ts-Set-T9-in-mxt_resume-bas.patch"

	echo "dir: ssd130x"
	${git} "${DIR}/patches/ssd130x/0001-video-ssd1307fb-Add-support-for-SSD1306-OLED-control.patch"
	${git} "${DIR}/patches/ssd130x/0002-ssd1307fb-Rework-the-communication-functions.patch"
	${git} "${DIR}/patches/ssd130x/0003-ssd1307fb-Speed-up-the-communication-with-the-contro.patch"
	${git} "${DIR}/patches/ssd130x/0004-ssd1307fb-Make-use-of-horizontal-addressing-mode.patch"
	${git} "${DIR}/patches/ssd130x/0005-SSD1307fb-1Hz-8Hz-defio-updates.patch"

	echo "dir: build"
	#${git} "${DIR}/patches/build/0001-ARM-force-march-armv7a-for-thumb2-builds-http-lists..patch"
	#${git} "${DIR}/patches/build/0002-headers_install-Fix-build-failures-on-deep-directory.patch"
	#${git} "${DIR}/patches/build/0003-libtraceevent-Remove-hard-coded-include-to-usr-local.patch"
	${git} "${DIR}/patches/build/0004-Make-single-.dtb-targets-also-with-DTC_FLAGS.patch"

	echo "dir: hdmi"
	${git} "${DIR}/patches/hdmi/0001-video-Add-generic-HDMI-infoframe-helpers.patch"
	${git} "${DIR}/patches/hdmi/0002-BeagleBone-Black-TDA998x-Initial-HDMI-Audio-support.patch"
	${git} "${DIR}/patches/hdmi/0003-Clean-up-some-formating-and-debug-in-Davinci-MCASP-d.patch"
	${git} "${DIR}/patches/hdmi/0004-tilcdc-Prune-modes-that-can-t-support-audio.patch"
	${git} "${DIR}/patches/hdmi/0005-Enable-output-of-correct-AVI-Infoframe-type-hdmi.patch"
	${git} "${DIR}/patches/hdmi/0006-drm-am335x-add-support-for-2048-lines-vertical.patch"
	${git} "${DIR}/patches/hdmi/0007-drm-tda998x-Adding-extra-CEA-mode-for-1920x1080-24.patch"
	${git} "${DIR}/patches/hdmi/0008-tilcdc-Remove-superfluous-newlines-from-DBG-messages.patch"
	${git} "${DIR}/patches/hdmi/0009-tilcdc-1280x1024x60-bw-1920x1080x24-bw.patch"
	${git} "${DIR}/patches/hdmi/0010-tilcdc-Only-support-Audio-on-50-60-Hz-modes.patch"
	${git} "${DIR}/patches/hdmi/0011-drm-i2c-nxp-tda998x-fix-EDID-reading-on-TDA19988-dev.patch"
	${git} "${DIR}/patches/hdmi/0012-tilcdc-Allow-non-audio-modes-when-we-don-t-support-t.patch"
	${git} "${DIR}/patches/hdmi/0013-drm-i2c-nxp-tda998x-ensure-VIP-output-mux-is-properl.patch"
	${git} "${DIR}/patches/hdmi/0014-drm-i2c-nxp-tda998x-fix-npix-nline-programming.patch"
	${git} "${DIR}/patches/hdmi/0015-drm-tilcdc-Clear-bits-of-register-we-re-going-to-set.patch"
	${git} "${DIR}/patches/hdmi/0016-DRM-tda998x-add-missing-include.patch"
	${git} "${DIR}/patches/hdmi/0017-drm-i2c-nxp-tda998x-prepare-for-video-input-configur.patch"
	${git} "${DIR}/patches/hdmi/0018-WIP-of-new-tda998x-patches.patch"
	${git} "${DIR}/patches/hdmi/0019-tilcdc-Slave-panel-settings-read-from-DT-now.patch"
	${git} "${DIR}/patches/hdmi/0020-drm-tda998x-Revert-WIP-to-previous-state.patch"
	${git} "${DIR}/patches/hdmi/0021-tilcdc-More-refined-audio-mode-compatibility-check.patch"
	${git} "${DIR}/patches/hdmi/0022-drm-tilcdc-fixing-i2c-slave-initialization-race.patch"
	${git} "${DIR}/patches/hdmi/0023-drm-tilcdc-increase-allowable-supported-resolution.patch"
	${git} "${DIR}/patches/hdmi/0024-drm-i2c-tda998x-fix-sync-generation-and-calculation.patch"
	${git} "${DIR}/patches/hdmi/0025-drm-tilcdc-fixup-mode-to-workaound-sync-for-tda998x.patch"
	${git} "${DIR}/patches/hdmi/0026-Documentation-for-tilcdc-Devicetree-Bindings.patch"
	${git} "${DIR}/patches/hdmi/0027-drm-tilcdc-adding-more-guards-to-prevent-selecting-i.patch"

	${git} "${DIR}/patches/audio/0001-Make-the-McASP-code-generic-again-remove-all-hardcod.patch"
	${git} "${DIR}/patches/audio/0002-ASoc-Davinci-EVM-Config-12MHz-CLK-for-AIC3x-Codec.patch"
	${git} "${DIR}/patches/audio/0003-ASoc-McASP-Lift-Reset-on-CLK-Dividers-when-RX-TX.patch"

	echo "dir: resetctrl"
	${git} "${DIR}/patches/resetctrl/0001-boneblack-Remove-default-pinmuxing-for-MMC1.patch"
	${git} "${DIR}/patches/resetctrl/0002-capemgr-Implement-cape-priorities.patch"
	${git} "${DIR}/patches/resetctrl/0003-rstctl-Reset-control-subsystem.patch"
	${git} "${DIR}/patches/resetctrl/0004-omap_hsmmc-Enable-rstctl-bindings.patch"
	${git} "${DIR}/patches/resetctrl/0005-bone-Add-rstctl-DT-binding-for-beaglebone.patch"
	${git} "${DIR}/patches/resetctrl/0006-bone-eMMC-Add-rstctl-rstctl-DT-bindings.patch"
	${git} "${DIR}/patches/resetctrl/0007-capes-Add-testing-capes-for-rstctl.patch"
	${git} "${DIR}/patches/resetctrl/0008-omap_hsmmc-Bail-out-when-rstctl-error-is-unrecoverab.patch"
	${git} "${DIR}/patches/resetctrl/0009-bone-Put-priorities-in-built-in-capes.patch"
	${git} "${DIR}/patches/resetctrl/0010-bone-common-dtsi-remove-reset-cape.patch"
	${git} "${DIR}/patches/resetctrl/0011-mmc-add-missing-select-RSTCTL-in-MMC_OMAP.patch"

	echo "dir: camera"
	${git} "${DIR}/patches/camera/0001-soc_camera-QL-mt9l112-camera-driver-for-the-beaglebo.patch"
	${git} "${DIR}/patches/camera/0002-capes-Add-BB-BONE-CAM3-cape.patch"
	${git} "${DIR}/patches/camera/0003-cssp_camera-Correct-license-identifier.patch"
	${git} "${DIR}/patches/camera/0004-cssp_camera-increase-delays-make-sensor-detection-wo.patch"
	${git} "${DIR}/patches/camera/0005-mt9t112-forward-port-optimizations-from-Angstrom-3.2.patch"
	${git} "${DIR}/patches/camera/0006-cssp_camera-Use-flip-if-available.patch"
	${git} "${DIR}/patches/camera/0007-cssp_camera-Fix-it-for-small-resolutions.patch"
	${git} "${DIR}/patches/camera/0008-cssp_camera-Increase-delay-after-enabling-clocks-to-.patch"
	${git} "${DIR}/patches/camera/0009-Debugging-camera-stuff.patch"
	${git} "${DIR}/patches/camera/0010-cssp_camera-Make-it-work-with-Beaglebone-black.patch"

	echo "dir: resources"
	${git} "${DIR}/patches/resources/0001-bone-capemgr-Introduce-simple-resource-tracking.patch"
	${git} "${DIR}/patches/resources/0002-capes-Add-resources-to-capes.patch"
	${git} "${DIR}/patches/resources/0003-capes-Update-most-of-the-capes-with-resource-definit.patch"
	${git} "${DIR}/patches/resources/0004-capes-Update-RS232-CAN-capes-with-resources.patch"
	${git} "${DIR}/patches/resources/0005-capemgr-Add-enable_partno-parameter.patch"
	${git} "${DIR}/patches/resources/0006-cape-GPIOHELP-use-correct-part-number.patch"
	${git} "${DIR}/patches/resources/0007-bbb-Add-a-fall-back-non-audio-HDMI-cape.patch"
	${git} "${DIR}/patches/resources/0008-capes-HDMI-slaves-need-panel-settings.patch"
	${git} "${DIR}/patches/resources/0009-capes-boneblack-HDMI-capes-have-blacklisted-modes.patch"
	${git} "${DIR}/patches/resources/0010-capes-LCD7-Fix-definitions.patch"
	${git} "${DIR}/patches/resources/0011-capes-LCD7-Fix-enter-key-pinmux.patch"
	${git} "${DIR}/patches/resources/0012-Fix-timings-for-LCD3-cape.patch"
	${git} "${DIR}/patches/resources/0013-capes-LCD-capes-updated-with-timing-fixes.patch"
	${git} "${DIR}/patches/resources/0014-Fix-mmc2-being-enabled-when-eMMC-is-disabled.patch"
	${git} "${DIR}/patches/resources/0015-capes-LCD7-fix-vsync-len-off-by-one.patch"
	${git} "${DIR}/patches/resources/0016-LCD-capes-set-default-brightness-to-100.patch"
	${git} "${DIR}/patches/resources/0017-lcd-capes-update-adc-channels.patch"
	${git} "${DIR}/patches/resources/0018-bone-renamed-adafruit-RTC-cape.patch"
	${git} "${DIR}/patches/resources/0019-bone-add-PPS-to-BB-BONE-RTC-cape.patch"
	${git} "${DIR}/patches/resources/0020-firmware-remove-rule-for-cape-bone-adafruit-lcd-00A0.patch"
	${git} "${DIR}/patches/resources/0021-hwmon-add-driver-for-the-AM335x-bandgap-temperature-.patch"
#disabled, as 'cape' fails verification and does not load...
#	${git} "${DIR}/patches/resources/0022-fw-Make-firmware-timeout-loading-value-configurable.patch"
#	${git} "${DIR}/patches/resources/0023-capemgr-Retry-loading-when-failure-to-find-firmware.patch"
	${git} "${DIR}/patches/resources/0024-arm-bone-dts-add-CD-for-mmc1.patch"

	echo "dir: pmic"
	${git} "${DIR}/patches/pmic/0001-tps65217-Enable-KEY_POWER-press-on-AC-loss-PWR_BUT.patch"
	${git} "${DIR}/patches/pmic/0002-dt-bone-common-Add-interrupt-for-PMIC.patch"

	echo "dir: pps"
	${git} "${DIR}/patches/pps/0001-drivers-pps-clients-pps-gpio.c-convert-to-module_pla.patch"
	${git} "${DIR}/patches/pps/0002-drivers-pps-clients-pps-gpio.c-convert-to-devm_-help.patch"
	${git} "${DIR}/patches/pps/0003-pps-gpio-add-device-tree-binding-and-support.patch"
	${git} "${DIR}/patches/pps/0004-pps-gpio-add-pinctrl-suppport.patch"

	echo "dir: leds"
	${git} "${DIR}/patches/leds/0001-leds-leds-pwm-Convert-to-use-devm_get_pwm.patch"
	${git} "${DIR}/patches/leds/0002-leds-leds-pwm-Preparing-the-driver-for-device-tree-s.patch"
	${git} "${DIR}/patches/leds/0003-leds-leds-pwm-Simplify-cleanup-code.patch"
	${git} "${DIR}/patches/leds/0004-leds-leds-pwm-Add-device-tree-bindings.patch"
	${git} "${DIR}/patches/leds/0005-leds-leds-pwm-Defer-led_pwm_set-if-PWM-can-sleep.patch"
	${git} "${DIR}/patches/leds/0006-leds-pwm-Enable-compilation-on-this-version-of-the-k.patch"

	echo "dir: capes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/capes/0001-capes-Add-bacon-cape.patch"
	${git} "${DIR}/patches/capes/0002-cape-bacon-Cosmetic-change-of-the-adc-helper-name.patch"
	${git} "${DIR}/patches/capes/0003-cape-bacon-educational-edition.patch"
	${git} "${DIR}/patches/capes/0004-capes-bacon-Update-with-new-ADC-driver-method.patch"
	${git} "${DIR}/patches/capes/0005-capes-BACON-Educational-cape-with-free-form-muxing.patch"
	${git} "${DIR}/patches/capes/0006-firmware-add-BeBoPr-cape.patch"
	${git} "${DIR}/patches/capes/0007-Add-support-for-Beaglebone-Audio-Amplifier-Cape.patch"
	${git} "${DIR}/patches/capes/0008-capemgr-Priority-on-capemgr.enable_partno-option.patch"
	${git} "${DIR}/patches/capes/0009-bone-add-protocape-GPS.patch"
	${git} "${DIR}/patches/capes/0010-capes-make-SPI-overlays-SPIDEV-by-default.patch"
	${git} "${DIR}/patches/capes/0011-Removed-old-wrong-BeBoPr-2191-R2-overlay.patch"
	${git} "${DIR}/patches/capes/0012-Workaround-for-bug-in-tscadc-code-that-oopses-with-B.patch"
	${git} "${DIR}/patches/capes/0013-DT-overlay-for-BeBoPr-and-BeagleBone-white-.-Loaded-.patch"
	${git} "${DIR}/patches/capes/0014-Added-alias-for-BeBoPrs-with-old-EEPROM-device-id-21.patch"
	${git} "${DIR}/patches/capes/0015-DT-overlay-for-BeBoPr-with-enable-patch-and-BeagleBo.patch"
	${git} "${DIR}/patches/capes/0016-DT-overlay-for-BeBoPr-Bridge-and-BeagleBone-any-colo.patch"
	${git} "${DIR}/patches/capes/0017-Removed-Whitelist-and-Blacklist-Modes-From-HDMI-Devi.patch"
	${git} "${DIR}/patches/capes/0018-beaglebone-capes-add-replicape-A2-and-A3-support.patch"
	${git} "${DIR}/patches/capes/0019-Added-camera-cape-support-for-Beaglebone-Black.patch"
	${git} "${DIR}/patches/capes/0020-add-argus-ups-cape-support.patch"
	${git} "${DIR}/patches/capes/0021-Fix-aspect-ratio-issue-of-720p-in-MT9M114-camera-cap.patch"
	${git} "${DIR}/patches/capes/0022-beaglebone-capes-Added-overlays-for-CBB-Serial-cape.patch"
	${git} "${DIR}/patches/capes/0023-apply-htu21-patch.patch"
	${git} "${DIR}/patches/capes/0024-add-support-for-weather-cape-rev-b.patch"
	${git} "${DIR}/patches/capes/0025-capes-Add-cape-universal-overlay-files-More-details-.patch"
	${git} "${DIR}/patches/capes/0026-remove-1-wire-gpio-in-weather-cape-rev-B.patch"
	${git} "${DIR}/patches/capes/0027-cape-add-cape-bone-ibb-00A0.dts.patch"
	${git} "${DIR}/patches/capes/0028-adds-DTS-for-CryptoCape.patch"
	${git} "${DIR}/patches/capes/0029-Provides-a-sysfs-interface-to-the-eQEP-hardware-on-t.patch"
	${git} "${DIR}/patches/capes/0030-capes-add-bone_eqep-from-https-github.com-Teknoman11.patch"
	${git} "${DIR}/patches/capes/0031-Adding-Logibone-to-cape-support-list.patch"
	${git} "${DIR}/patches/capes/0032-beaglebone-capes-Added-CBB-Relay-cape-dt-overlay.patch"
	${git} "${DIR}/patches/capes/0033-Firmware-Update-Replicape-device-tree-overlay-files-.patch"
	${git} "${DIR}/patches/capes/0034-cape-add-BB-BONE-AUDI-02-00A0-from-http-elinux.org-C.patch"
	${git} "${DIR}/patches/capes/0035-cape-universaln-remove-P9_31.patch"
	${git} "${DIR}/patches/capes/0036-cape-add-BB-BONE-HAS-00R1.patch"
	${git} "${DIR}/patches/capes/0037-cape-add-BB-BONE-SERL-01-00A2.patch"
	${git} "${DIR}/patches/capes/0038-cape-add-NL-AB-BBBC-00D0.patch"
	${git} "${DIR}/patches/capes/0039-add-cape-MT-CAPE-01-still-needs-gpiolib-mtctrl-patch.patch"
	${git} "${DIR}/patches/capes/0040-cape-LCD4-Fix-GPIO-buttons-Correct-errant-GPIO-setti.patch"
	${git} "${DIR}/patches/capes/0041-capes-HDMI-Fix-incorrect-pinmux-register-for-GPIO1_2.patch"
	${git} "${DIR}/patches/capes/0042-beaglebone-universal-io-sync-with-master-of-https-gi.patch"
	${git} "${DIR}/patches/capes/0043-nimbelink-add-missing-ids.patch"
	${git} "${DIR}/patches/capes/0044-capes-add-BB-MIKROBUS-01-00A1.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=44
		cleanup
	fi

	echo "dir: proto"
	${git} "${DIR}/patches/proto/0001-add-new-default-pinmux-based-on-Proto-Cape.patch"

	echo "dir: logibone"
	${git} "${DIR}/patches/logibone/0001-Instering-Logibone-driver-into-kernel.patch"
	${git} "${DIR}/patches/logibone/0002-Adding-DTS-support-for-Logibone.patch"
	${git} "${DIR}/patches/logibone/0003-Moving-from-bit-banged-configuration-to-SPI.patch"
	${git} "${DIR}/patches/logibone/0004-removing-fpga-loading-interface-from-kernel-space.patch"
	${git} "${DIR}/patches/logibone/0005-adding-pin-exlusive-property-to-device-tree-file.patch"
#	${git} "${DIR}/patches/logibone/0006-Small-accesses-are-not-using-EDMA.patch"
	echo "dir: BeagleLogic"
	${git} "${DIR}/patches/BeagleLogic/0001-Add-DTS-for-BeagleLogic.patch"
	${git} "${DIR}/patches/BeagleLogic/0002-Add-BeagleLogic-binding-functions-to-pru_rproc.patch"
	${git} "${DIR}/patches/BeagleLogic/0003-Add-kernel-module-for-BeagleLogic.patch"
	${git} "${DIR}/patches/BeagleLogic/0004-Fix-compile-error-with-pru_rproc.c.patch"
	${git} "${DIR}/patches/BeagleLogic/0005-BeagleLogic-module-v1.1-working-with-libsigrok.patch"

	echo "dir: fixes"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/fixes/0001-sync-don-t-block-the-flusher-thread-waiting-on-IO.patch"
	${git} "${DIR}/patches/fixes/0002-USB-Fix-USB-device-disconnects-on-resume.patch"
	${git} "${DIR}/patches/fixes/0003-beaglebone-switch-uSD-to-4-bit-mode.patch"
	${git} "${DIR}/patches/fixes/0004-mmc-omap_hsmmc-clear-status-flags-before-starting-a-.patch"
	${git} "${DIR}/patches/fixes/0005-uvcvideo-Fix-data-type-for-pan-tilt-control.patch"
	${git} "${DIR}/patches/fixes/0006-ti_am335x_tsc-touchscreen-jitter-fix.patch"
	${git} "${DIR}/patches/fixes/0007-omap-RS485-support-by-Michael-Musset.patch"
	${git} "${DIR}/patches/fixes/0008-deb-pkg-sync-with-v3.14.patch"
	${git} "${DIR}/patches/fixes/0009-Fix-for-a-part-of-video-got-flipped-from-bottom-to-t.patch"
	${git} "${DIR}/patches/fixes/0010-modified-drivers-tty-serial-omap-serial.c-the-change.patch"
	${git} "${DIR}/patches/fixes/0011-PWM-period-control.patch"
	${git} "${DIR}/patches/fixes/0012-PWM-period-control.patch"
	${git} "${DIR}/patches/fixes/0013-Add-MODULE_ALIAS.patch"
	${git} "${DIR}/patches/fixes/0014-Add-MODULE_ALIAS.patch"
	${git} "${DIR}/patches/fixes/0015-Add-MODULE_ALIAS.patch"
	${git} "${DIR}/patches/fixes/0016-Updated-defines-to-fully-work-with-BeagleBone.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=16
		cleanup
	fi

	echo "dir: tre"
	${git} "${DIR}/patches/tre/0001-Arduino-Tre-added.patch"
	${git} "${DIR}/patches/tre/0002-arduino-tre.dts-remote-trailing-whitespace.patch"
	${git} "${DIR}/patches/tre/0003-arduino-tre.dts-update-vdd_ddr-regulator-to-1.35V.patch"

	echo "dir: pruspeak"
	${git} "${DIR}/patches/pruspeak/0001-pruspeak-imported-original-source.patch"
	${git} "${DIR}/patches/pruspeak/0002-pru_speak-integrated-with-pru_rproc-in-bb.org-3.8-ke.patch"
	${git} "${DIR}/patches/pruspeak/0003-pru_speak-fix-dma-mask.patch"
	${git} "${DIR}/patches/pruspeak/0004-Add-DTS-for-PRUSPEAK.patch"

	echo "dir: firmware"
	#http://arago-project.org/git/projects/?p=am33x-cm3.git;a=summary
	#http://arago-project.org/git/projects/?p=am33x-cm3.git;a=commit;h=750362868d914702086187096ec2c67b68eac101
	#
	#git clone git://arago-project.org/git/projects/am33x-cm3.git
	#2258d3e13beafb33b119e7ee2b819810  am33x-cm3/bin/am335x-pm-firmware.bin
	#cp -v ../am33x-cm3/bin/am335x-pm-firmware.bin ./firmware/
	#git add -f ./firmware/am335x-pm-firmware.bin
	${git} "${DIR}/patches/firmware/0001-firmware-add-for-beaglebone.patch"
}

saucy () {
	echo "dir: saucy"
	${git} "${DIR}/patches/saucy/0001-saucy-disable-Werror-pointer-sign.patch"
	${git} "${DIR}/patches/saucy/0002-saucy-disable-stack-protector.patch"
}

machinekit () {
	echo "dir: machinekit"
	#${git} "${DIR}/patches/machinekit/0001-ADS1115.patch"
	# Fix now applied by upstream (see dir: fixes, above)
	#${git} "${DIR}/patches/machinekit/0002-omap_hsmmc-clear-status-flags-before-starting-a-new-command.patch"
	${git} "${DIR}/patches/machinekit/0001-Add-dir-changeable-property-to-gpio-of-helper.patch"
}

sgx () {
	echo "dir: sgx"
	${git} "${DIR}/patches/sgx/0001-OpenGl-added-SGX-device-to-device-tree.patch"
	${git} "${DIR}/patches/sgx/0002-OpenGL-apply-SGX-patch-from-TI-forum-FIXES-crash-aft.patch"
	${git} "${DIR}/patches/sgx/0003-OpenGL-fixed-IRQ-offset.patch"
	${git} "${DIR}/patches/sgx/0004-SGX-am335x_feature_detection.patch"
}

backports () {
	echo "dir: backports"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/backports/0001-backport-v3.13.7-tpm_i2c_atmel.c.patch"
	${git} "${DIR}/patches/backports/0002-backport-am335x-ti-omap4-rng-from-ti-v3.12-bsp.patch"
	${git} "${DIR}/patches/backports/0003-ARM-OMAP-Add-function-to-request-timer-by-node.patch"
	${git} "${DIR}/patches/backports/0004-pps-use-an-external-clock-source-on-pin-P9.41-TCLKIN.patch"
	${git} "${DIR}/patches/backports/0005-add-pps-gmtimer-from-https-github.com-ddrown-pps-gmt.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=5
		cleanup
	fi
}

probotix () {
	echo "dir: probotix"
	${git} "${DIR}/patches/probotix/0001-Add-Probotix-custom-LCD-device-tree-overlay.patch"
}

pcm512x () {
	echo "dir: pcm512x"
	${git} "${DIR}/patches/pcm512x/0001-ASoC-pcm512x-Add-PCM512x-driver.patch"
	${git} "${DIR}/patches/pcm512x/0002-ASoC-pcm512x-More-constification.patch"
	${git} "${DIR}/patches/pcm512x/0003-ASoC-pcm512x-Implement-paging-support.patch"
	${git} "${DIR}/patches/pcm512x/0004-ASoC-pcm512x-Implement-analogue-volume-control.patch"
	${git} "${DIR}/patches/pcm512x/0005-ASoC-pcm512x-Split-out-bus-drivers.patch"
	${git} "${DIR}/patches/pcm512x/0006-ASoC-pcm512x-Fix-duplicate-const-warning.patch"
	${git} "${DIR}/patches/pcm512x/0007-ASoC-pcm512x-Use-CONFIG_PM_RUNTIME-macro.patch"
	${git} "${DIR}/patches/pcm512x/0008-ASoC-pcm512x-Replace-usage-deprecated-SOC_VALUE_ENUM.patch"
	${git} "${DIR}/patches/pcm512x/0009-ASoC-pcm512x-Correct-Digital-Playback-control-names.patch"
	${git} "${DIR}/patches/pcm512x/0010-ASoC-pcm512x-Trigger-auto-increment-of-register-addr.patch"
	${git} "${DIR}/patches/pcm512x/0011-ASoC-pcm512x-Also-support-PCM514x-devices.patch"
	${git} "${DIR}/patches/pcm512x/0012-ASoC-pcm512x-Fix-DSP-program-selection.patch"
	${git} "${DIR}/patches/pcm512x/0013-ALSA-pcm-Add-snd_interval_ranges-and-snd_pcm_hw_cons.patch"
	${git} "${DIR}/patches/pcm512x/0014-ASoC-pcm512x-Fix-spelling-of-register-field-names.patch"
	${git} "${DIR}/patches/pcm512x/0015-ASoC-pcm512x-Support-mastering-BCLK-LRCLK-without-us.patch"
	${git} "${DIR}/patches/pcm512x/0016-ASoC-pcm512x-Support-mastering-BCLK-LRCLK-using-the-.patch"
	${git} "${DIR}/patches/pcm512x/0017-ASoC-pcm512x-Avoid-the-PLL-for-the-DAC-clock-if-poss.patch"
	${git} "${DIR}/patches/pcm512x/0018-ASoC-pcm512x-Support-SND_SOC_DAIFMT_CBM_CFS.patch"
	${git} "${DIR}/patches/pcm512x/0019-ASoC-pcm512x-Fixup-warning-splat.patch"
	${git} "${DIR}/patches/pcm512x/0020-ASoC-pcm512x-Use-the-correct-range-constraints-for-S.patch"
}

beagleboy () {
	echo "dir: BeagleBoy"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/BeagleBoy/0001-ST-lsm303dlhc-driver-added.patch"
	${git} "${DIR}/patches/BeagleBoy/0002-ST-lsm303dlhc-header-file-moved-to-correct-location.patch"
	${git} "${DIR}/patches/BeagleBoy/0003-ST-lsm303dlhc-patched-for-build-against-3.8-kernel.patch"
	${git} "${DIR}/patches/BeagleBoy/0004-ST-lsm330-driver.patch"
	${git} "${DIR}/patches/BeagleBoy/0005-ST-lsm330-added-to-build.patch"
	${git} "${DIR}/patches/BeagleBoy/0006-cape-BEAGLEBOY-0013.dts.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=6
		cleanup
	fi
}

treewide () {
	#anything that touches every cape....
	echo "dir: tree-wide"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi
	${git} "${DIR}/patches/tree-wide/0001-add-am335x-bonegreen.patch"
	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi
}

gcc5 () {
	echo "dir: gcc5"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/gcc5/0001-kernel-add-support-for-gcc-5.patch"
	${git} "${DIR}/patches/gcc5/0002-kernel-use-the-gnu89-standard-explicitly.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

emmc () {
	echo "dir: emmc"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/emmc/0001-mmc-core-Update-the-ext-csd.rev-check-for-eMMC5.1.patch"
	${git} "${DIR}/patches/emmc/0002-mmc-Allow-forward-compatibility-for-eMMC.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=2
		cleanup
	fi
}

cape_universal () {
	echo "dir: cape_universal"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/cape_universal/0001-sync-beaglebone-universal-io-Sep-25-2016.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="cape_universal"
		number=1
		cleanup
	fi
}

gcc6 () {
	echo "dir: gcc6"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/gcc6/0001-gcc6-backport-compiler-gcc-integrate-the-various-com.patch"
	${git} "${DIR}/patches/gcc6/0002-kbuild-add-fno-PIE.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="gcc6"
		number=2
		cleanup
	fi
}

add_board_to_kernel_makefile () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$board' \\:g' arch/arm/boot/dts/Makefile
}

clone_board () {
	cp -v ./arch/arm/boot/dts/${base}s ./arch/arm/boot/dts/${clone}s
	board=${clone}b
	add_board_to_kernel_makefile
	${git} add ./arch/arm/boot/dts/${clone}s
}

more_boards () {
	echo "dir: more_boards"

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		base="am335x-boneblack.dt"
		clone="am335x-boneblack-wireless.dt"
		clone_board

		base="am335x-bonegreen.dt"
		clone="am335x-bonegreen-wireless.dt"
		clone_board

		${git} commit -a -m 'auto generated: more_boards' -s
		if [ ! -f ../patches/more_boards/ ] ; then
			mkdir -p ../patches/more_boards/
		fi
		${git} format-patch -1 -o ../patches/more_boards/
		exit 2
	fi

	${git} "${DIR}/patches/more_boards/0001-auto-generated-more_boards.patch"
	${git} "${DIR}/patches/more_boards/0002-bbgw-bbbw-disable-mac.patch"
}


bb_view_lcd () {
#element14_bb_view: breaks lcd4
	echo "dir: bb_view_lcd"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/bb_view_lcd/0001-capes-element14_bb_view_lcd_capes.patch"
	${git} "${DIR}/patches/bb_view_lcd/0002-sitara_red_blue_swap_workaround.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="bb_view_lcd"
		number=2
		cleanup
	fi
}

am33x
arm
omap
am33x_after
saucy
machinekit
sgx
backports
probotix
pcm512x
beagleboy
treewide
gcc5
emmc
cape_universal
gcc6
more_boards

#element14_bb_view: breaks lcd4
#bb_view_lcd

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
