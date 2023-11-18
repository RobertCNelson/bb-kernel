#!/bin/bash -e
#
# Copyright (c) 2009-2023 Robert Nelson <robertcnelson@gmail.com>
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

wpanusb () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./wpanusb ] ; then
			rm -rf ./wpanusb || true
		fi

		${git_bin} clone https://git.beagleboard.org/beagleconnect/linux/wpanusb --depth=1
		cd ./wpanusb
			wpanusb_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cp -v ../wpanusb/wpanusb.h drivers/net/ieee802154/
		cp -v ../wpanusb/wpanusb.c drivers/net/ieee802154/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: wpanusb: https://git.beagleboard.org/beagleconnect/linux/wpanusb' -m "https://git.beagleboard.org/beagleconnect/linux/wpanusb/-/commit/${wpanusb_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/wpanusb/
		echo "WPANUSB: https://git.beagleboard.org/beagleconnect/linux/wpanusb/-/commit/${wpanusb_hash}" > ../patches/external/git/WPANUSB

		rm -rf ../wpanusb/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/external/wpanusb/0001-merge-wpanusb-https-git.beagleboard.org-beagleconnec.patch"

		wdir="external/wpanusb"
		number=1
		cleanup

		exit 2
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

		${git_bin} clone https://git.beagleboard.org/beagleconnect/linux/bcfserial.git --depth=1
		cd ./bcfserial
			bcfserial_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		cp -v ../bcfserial/bcfserial.c drivers/net/ieee802154/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: bcfserial: https://git.beagleboard.org/beagleconnect/linux/bcfserial.git' -m "https://git.beagleboard.org/beagleconnect/linux/bcfserial/-/commit/${bcfserial_hash}" -s
		${git_bin} format-patch -1 -o ../patches/external/bcfserial/
		echo "BCFSERIAL: https://git.beagleboard.org/beagleconnect/linux/bcfserial/-/commit/${bcfserial_hash}" > ../patches/external/git/BCFSERIAL

		rm -rf ../bcfserial/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/external/bcfserial/0001-merge-bcfserial-https-git.beagleboard.org-beagleconn.patch"

		wdir="external/bcfserial"
		number=1
		cleanup

		exit 2
	fi
	dir 'external/bcfserial'
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	rt_patch="${KERNEL_REL}${kernel_rt}"

	#${git_bin} revert --no-edit xyz

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/older/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -m "patch-${rt_patch}.patch.xz" -s
		${git_bin} format-patch -1 -o ../patches/external/rt/
		echo "RT: patch-${rt_patch}.patch.xz" > ../patches/external/git/RT

		exit 2
	fi
	dir 'external/rt'
}

wireless_regdb () {
	#https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./wireless-regdb ] ; then
			rm -rf ./wireless-regdb || true
		fi

		${git_bin} clone git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git --depth=1
		cd ./wireless-regdb
			wireless_regdb_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../wireless-regdb/regulatory.db ./firmware/
		cp -v ../wireless-regdb/regulatory.db.p7s ./firmware/
		${git_bin} add -f ./firmware/regulatory.*
		${git_bin} commit -a -m 'Add wireless-regdb regulatory database file' -m "https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" -s

		${git_bin} format-patch -1 -o ../patches/external/wireless_regdb/
		echo "WIRELESS_REGDB: https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/commit/?id=${wireless_regdb_hash}" > ../patches/external/git/WIRELESS_REGDB

		rm -rf ../wireless-regdb/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/external/wireless_regdb/0001-Add-wireless-regdb-regulatory-database-file.patch"

		wdir="external/wireless_regdb"
		number=1
		cleanup
	fi
	dir 'external/wireless_regdb'
}

ti_pm_firmware () {
	#https://git.ti.com/gitweb?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=shortlog;h=refs/heads/ti-v4.1.y
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ -d ./ti-amx3-cm3-pm-firmware ] ; then
			rm -rf ./ti-amx3-cm3-pm-firmware || true
		fi

		${git_bin} clone -b ti-v4.1.y git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
		cd ./ti-amx3-cm3-pm-firmware
			ti_amx3_cm3_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../ti-amx3-cm3-pm-firmware/bin/am* ./firmware/

		${git_bin} add -f ./firmware/am*
		${git_bin} commit -a -m 'Add AM335x CM3 Power Managment Firmware' -m "http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" -s
		${git_bin} format-patch -1 -o ../patches/drivers/ti/firmware/
		echo "TI_AMX3_CM3: http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" > ../patches/external/git/TI_AMX3_CM3

		rm -rf ../ti-amx3-cm3-pm-firmware/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/drivers/ti/firmware/0001-Add-AM335x-CM3-Power-Managment-Firmware.patch"

		wdir="drivers/ti/firmware"
		number=1
		cleanup
	fi
	dir 'drivers/ti/firmware'
}

cleanup_dts_builds () {
	rm -rf arch/arm/boot/dts/modules.order || true
	rm -rf arch/arm/boot/dts/.*cmd || true
	rm -rf arch/arm/boot/dts/.*tmp || true
	rm -rf arch/arm/boot/dts/*dtb || true
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beagleboard_dtbs () {
	branch="v5.6.x"
	https_repo="https://github.com/beagleboard/BeagleBoard-DeviceTrees"
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

		mkdir -p arch/arm/boot/dts/overlays/
		cp -vr ../${work_dir}/src/arm/* arch/arm/boot/dts/
		cp -vr ../${work_dir}/include/dt-bindings/* ./include/dt-bindings/

		device="am335x-abbbi.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-gateway.dtb" ; dtb_makefile_append

		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append
		device="am335x-sancloud-bbe-uboot.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-sancloud-bbe-uboot-univ.dtb" ; dtb_makefile_append

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "${https_repo}/tree/${branch}" -m "${https_repo}/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/soc/ti/beagleboard_dtbs/
		echo "BBDTBS: ${https_repo}/commit/${git_hash}" > ../patches/git/BBDTBS

		rm -rf ../${work_dir}/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/soc/ti/beagleboard_dtbs/0001-Add-BeagleBoard.org-Device-Tree-Changes.patch"

		wdir="soc/ti/beagleboard_dtbs"
		number=1
		cleanup
	fi

	dir 'soc/ti/beagleboard_dtbs'
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
wpanusb
bcfserial
#rt
wireless_regdb
ti_pm_firmware
beagleboard_dtbs
#local_patch

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		${git_bin} checkout ${backport_tag} -b tmp
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f ; ${git_bin} branch -D tmp
		cd -
	fi

	rm -f arch/arm/boot/dts/overlays/*.dtbo || true
	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -m "Reference: ${backport_tag}" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
}

patch_backports (){
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

backports () {
	backport_tag="v5.12.19"

	subsystem="greybus"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/greybus/* ./drivers/greybus/
		cp -rv ~/linux-src/drivers/staging/greybus/* ./drivers/staging/greybus/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v5.12.19"

	subsystem="wlcore"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/ti/* ./drivers/net/wireless/ti/

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="1657f11c7ca109b6f7e7bec4e241bf6cbbe2d4b0"

	subsystem="exfat"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/staging/exfat/* ./drivers/staging/exfat/
		sed -i -e 's:CONFIG_EXFAT_FS:CONFIG_STAGING_EXFAT_FS:g' ./drivers/staging/Makefile

		post_backports
		exit 2
	else
		patch_backports
	fi

	backport_tag="v5.4.18"

	subsystem="brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/broadcom/brcm80211/* ./drivers/net/wireless/broadcom/brcm80211/
		cp -v ~/linux-src/include/uapi/linux/nl80211.h ./include/uapi/linux/nl80211.h
		cp -v ~/linux-src/include/linux/mmc/sdio_ids.h ./include/linux/mmc/sdio_ids.h

		post_backports

		#v5.4.18-2020_0402
		patch -p1 < ../patches/cypress/brcmfmac/0001-brcmfmac-set-F2-blocksize-and-watermark-for-4373.patch
		patch -p1 < ../patches/cypress/brcmfmac/0002-non-upstream-add-sg-parameters-dts-parsing.patch
		patch -p1 < ../patches/cypress/brcmfmac/0003-brcmfmac-set-apsta-to-0-when-AP-starts-on-primary-in.patch
		patch -p1 < ../patches/cypress/brcmfmac/0004-brcmfmac-support-AP-isolation.patch
		patch -p1 < ../patches/cypress/brcmfmac/0005-brcmfmac-make-firmware-eap_restrict-a-module-paramet.patch
		patch -p1 < ../patches/cypress/brcmfmac/0006-non-upstream-support-wake-on-ping-packet.patch
		patch -p1 < ../patches/cypress/brcmfmac/0007-non-upstream-remove-WOWL-configuration-in-disconnect.patch
		patch -p1 < ../patches/cypress/brcmfmac/0008-brcmfmac-make-setting-SDIO-workqueue-WQ_HIGHPRI-a-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0009-brcmfmac-remove-arp_hostip_clear-from-brcmf_netdev_s.patch
		patch -p1 < ../patches/cypress/brcmfmac/0010-brcmfmac-P2P-CERT-6.1.9-Support-GOUT-handling-P2P-Pr.patch
		patch -p1 < ../patches/cypress/brcmfmac/0011-brcmfmac-only-generate-random-p2p-address-when-neede.patch
		patch -p1 < ../patches/cypress/brcmfmac/0012-brcmfmac-increase-max-hanger-slots-from-1K-to-3K-in-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0013-brcmfmac-map-802.1d-priority-to-precedence-level-bas.patch
		patch -p1 < ../patches/cypress/brcmfmac/0014-brcmfmac-set-state-of-hanger-slot-to-FREE-when-flush.patch
		patch -p1 < ../patches/cypress/brcmfmac/0015-brcmfmac-add-RSDB-condition-when-setting-interface-c.patch
		patch -p1 < ../patches/cypress/brcmfmac/0016-brcmfmac-not-set-mbss-in-vif-if-firmware-does-not-su.patch
		patch -p1 < ../patches/cypress/brcmfmac/0017-brcmfmac-support-the-second-p2p-connection.patch
		patch -p1 < ../patches/cypress/brcmfmac/0018-brcmfmac-add-support-for-BCM4359-SDIO-chipset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0019-brcmfmac-send-port-authorized-event-for-FT-802.1X.patch
		patch -p1 < ../patches/cypress/brcmfmac/0020-brcmfmac-add-vendor-ie-for-association-responses.patch
		patch -p1 < ../patches/cypress/brcmfmac/0021-brcmfmac-fix-4339-CRC-error-under-SDIO-3.0-SDR104-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0022-brcmfmac-fix-the-incorrect-return-value-in-brcmf_inf.patch
		patch -p1 < ../patches/cypress/brcmfmac/0023-brcmfmac-Fix-double-freeing-in-the-fmac-usb-data-pat.patch
		patch -p1 < ../patches/cypress/brcmfmac/0024-brcmfmac-Fix-driver-crash-on-USB-control-transfer-ti.patch
		patch -p1 < ../patches/cypress/brcmfmac/0025-brcmfmac-avoid-network-disconnection-during-suspend-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0026-brcmfmac-allow-credit-borrowing-for-all-access-categ.patch
		patch -p1 < ../patches/cypress/brcmfmac/0027-non-upstream-Changes-to-improve-USB-Tx-throughput.patch
		patch -p1 < ../patches/cypress/brcmfmac/0028-brcmfmac-reset-two-D11-cores-if-chip-has-two-D11-cor.patch
		patch -p1 < ../patches/cypress/brcmfmac/0029-brcmfmac-introduce-module-parameter-to-configure-def.patch
		patch -p1 < ../patches/cypress/brcmfmac/0030-brcmfmac-configure-wowl-parameters-in-suspend-functi.patch
		patch -p1 < ../patches/cypress/brcmfmac/0031-brcmfmac-keep-SDIO-watchdog-running-when-console_int.patch
		patch -p1 < ../patches/cypress/brcmfmac/0032-brcmfmac-To-fix-kernel-crash-on-out-of-boundary-acce.patch
		patch -p1 < ../patches/cypress/brcmfmac/0033-brcmfmac-reduce-maximum-station-interface-from-2-to-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0034-brcmfmac-validate-ifp-pointer-in-brcmf_txfinalize.patch
		patch -p1 < ../patches/cypress/brcmfmac/0035-brcmfmac-clean-up-iface-mac-descriptor-before-de-ini.patch
		patch -p1 < ../patches/cypress/brcmfmac/0036-brcmfmac-To-fix-Bss-Info-flag-definition-Bug.patch
		patch -p1 < ../patches/cypress/brcmfmac/0037-brcmfmac-disable-command-decode-in-sdio_aos-for-4356.patch
		patch -p1 < ../patches/cypress/brcmfmac/0038-brcmfmac-increase-default-max-WOWL-patterns-to-16.patch
		patch -p1 < ../patches/cypress/brcmfmac/0039-non-upstream-Enable-Process-and-forward-PHY_TEMP-eve.patch
		patch -p1 < ../patches/cypress/brcmfmac/0040-brcmfmac-Use-FW-priority-definition-to-initialize-WM.patch
		patch -p1 < ../patches/cypress/brcmfmac/0041-brcmfmac-Fix-P2P-Group-Formation-failure-via-Go-neg-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0042-brcmfmac-Add-P2P-Action-Frame-retry-delay-to-fix-GAS.patch
		patch -p1 < ../patches/cypress/brcmfmac/0043-brcmfmac-Use-default-FW-priority-when-EDCA-params-sa.patch
		patch -p1 < ../patches/cypress/brcmfmac/0044-brcmfmac-fix-continuous-802.1x-tx-pending-timeout-er.patch
		patch -p1 < ../patches/cypress/brcmfmac/0045-brcmfmac-add-sleep-in-bus-suspend-and-cfg80211-resum.patch
		patch -p1 < ../patches/cypress/brcmfmac/0046-brcmfmac-fix-43455-CRC-error-under-SDIO-3.0-SDR104-m.patch
		patch -p1 < ../patches/cypress/brcmfmac/0047-brcmfmac-set-F2-blocksize-and-watermark-for-4359.patch
		patch -p1 < ../patches/cypress/brcmfmac/0048-brcmfmac-reserve-2-credits-for-host-tx-control-path.patch
		patch -p1 < ../patches/cypress/brcmfmac/0049-brcmfmac-update-tx-status-flags-to-sync-with-firmwar.patch
		patch -p1 < ../patches/cypress/brcmfmac/0050-brcmfmac-fix-credit-reserve-for-each-access-category.patch
		patch -p1 < ../patches/cypress/brcmfmac/0051-brcmfmac-fix-throughput-zero-stalls-on-PM-1-mode-due.patch
		patch -p1 < ../patches/cypress/brcmfmac/0052-brcmfmac-43012-Update-MES-Watermark.patch
		patch -p1 < ../patches/cypress/brcmfmac/0053-brcmfmac-add-support-for-CYW89359-SDIO-chipset.patch
		patch -p1 < ../patches/cypress/brcmfmac/0054-brcmfmac-add-CYW43570-PCIE-device.patch
		patch -p1 < ../patches/cypress/brcmfmac/0055-brcmfmac-Use-seq-seq_len-and-set-iv_initialize-when-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0056-brcmfmac-use-actframe_abort-to-cancel-ongoing-action.patch
		patch -p1 < ../patches/cypress/brcmfmac/0057-brcmfmac-fix-scheduling-while-atomic-issue-when-dele.patch
		patch -p1 < ../patches/cypress/brcmfmac/0058-brcmfmac-increase-message-buffer-size-for-control-pa.patch
		patch -p1 < ../patches/cypress/brcmfmac/0059-brcmfmac-Support-89459-pcie.patch
		patch -p1 < ../patches/cypress/brcmfmac/0060-brcmfmac-Fix-for-unable-to-return-to-visible-SSID.patch
		patch -p1 < ../patches/cypress/brcmfmac/0061-brcmfmac-Fix-for-wrong-disconnection-event-source-in.patch
		patch -p1 < ../patches/cypress/brcmfmac/0062-brcmfmac-add-support-for-SAE-authentication-offload.patch
		patch -p1 < ../patches/cypress/brcmfmac/0063-brcmfmac-Support-multiple-AP-interfaces-and-fix-STA-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0064-brcmfmac-Support-custom-PCIE-BAR-window-size.patch
		patch -p1 < ../patches/cypress/brcmfmac/0065-brcmfmac-set-F2-blocksize-and-watermark-for-4354.patch
		patch -p1 < ../patches/cypress/brcmfmac/0066-brcmfmac-support-for-virtual-interface-creation-from.patch
		patch -p1 < ../patches/cypress/brcmfmac/0067-brcmfmac-set-security-after-reiniting-interface.patch
		patch -p1 < ../patches/cypress/brcmfmac/0068-brcmfmac-increase-dcmd-maximum-buffer-size.patch
		patch -p1 < ../patches/cypress/brcmfmac/0069-brcmfmac-set-F2-blocksize-and-watermark-for-4356-SDI.patch
		patch -p1 < ../patches/cypress/brcmfmac/0070-brcmfmac-set-net-carrier-on-via-test-tool-for-AP-mod.patch
		patch -p1 < ../patches/cypress/brcmfmac/0071-nl80211-add-authorized-flag-back-to-ROAM-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0072-brcmfmac-set-authorized-flag-in-ROAM-event-for-offlo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0073-brcmfmac-set-authorized-flag-in-ROAM-event-for-PMK-c.patch
		patch -p1 < ../patches/cypress/brcmfmac/0074-nl80211-add-authorized-flag-to-CONNECT-event.patch
		patch -p1 < ../patches/cypress/brcmfmac/0075-brcmfmac-set-authorized-flag-in-CONNECT-event-for-PM.patch
		patch -p1 < ../patches/cypress/brcmfmac/0076-brcmfmac-add-support-for-Opportunistic-Key-Caching.patch
		patch -p1 < ../patches/cypress/brcmfmac/0077-nl80211-support-4-way-handshake-offloading-for-WPA-W.patch
		patch -p1 < ../patches/cypress/brcmfmac/0078-brcmfmac-support-4-way-handshake-offloading-for-WPA-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0079-nl80211-support-SAE-authentication-offload-in-AP-mod.patch
		patch -p1 < ../patches/cypress/brcmfmac/0080-brcmfmac-support-SAE-authentication-offload-in-AP-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0081-brcmfmac-add-USB-autosuspend-feature-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0082-brcmfmac-To-support-printing-USB-console-messages.patch
		patch -p1 < ../patches/cypress/brcmfmac/0083-brcmfmac-reset-SDIO-bus-on-a-firmware-crash.patch
		patch -p1 < ../patches/cypress/brcmfmac/0084-brcmfmac-fix-for-WPA-WPA2-PSK-4-way-handshake-and-SA.patch
		patch -p1 < ../patches/cypress/brcmfmac/0085-non-upstream-Fix-no-P2P-IE-in-probe-requests-issue.patch
		patch -p1 < ../patches/cypress/brcmfmac/0086-brcmfmac-add-54591-PCIE-device.patch
		patch -p1 < ../patches/cypress/brcmfmac/0087-brcmfmac-support-DS1-exit-firmware-re-download.patch
		patch -p1 < ../patches/cypress/brcmfmac/0088-brcmfmac-fix-43012-insmod-after-rmmod-in-DS1-failure.patch
		patch -p1 < ../patches/cypress/brcmfmac/0089-brcmfmac-fix-43012-driver-reload-failure-after-DS1-e.patch
		patch -p1 < ../patches/cypress/brcmfmac/0090-brcmfmac-reset-PMU-backplane-all-cores-in-CYW4373-du.patch
		patch -p1 < ../patches/cypress/brcmfmac/0091-brcmfmac-do-not-disconnect-for-disassoc-frame-from-u.patch
		patch -p1 < ../patches/cypress/brcmfmac/0092-brcmfmac-Set-pacing-shift-before-transmitting-skb-to.patch
		patch -p1 < ../patches/cypress/brcmfmac/0093-brcmfmac-fix-802.1d-priority-to-ac-mapping-for-pcie-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0094-non-upstream-calling-skb_orphan-before-sending-skb-t.patch
		patch -p1 < ../patches/cypress/brcmfmac/0095-non-upstream-workaround-for-4373-USB-WMM-5.2.27-test.patch
		patch -p1 < ../patches/cypress/brcmfmac/0096-brcmfmac-disable-command-decode-in-sdio_aos-for-4373.patch
		patch -p1 < ../patches/cypress/brcmfmac/0097-brcmfmac-disable-command-decode-in-sdio_aos-for-4339.patch
		patch -p1 < ../patches/cypress/brcmfmac/0098-brcmfmac-disable-command-decode-in-sdio_aos-for-4345.patch
		patch -p1 < ../patches/cypress/brcmfmac/0099-brcmfmac-support-the-forwarding-packet.patch
		patch -p1 < ../patches/cypress/brcmfmac/0100-brcmfmac-add-a-variable-for-packet-forwarding-condit.patch
		patch -p1 < ../patches/cypress/brcmfmac/0101-non-upstream-don-t-change-arp-nd-offload-in-multicas.patch

		#v5.4.18-2020_0625
		patch -p1 < ../patches/cypress/brcmfmac/0102-non-upstream-revert-don-t-change-arp-nd-offload-in-m.patch
		patch -p1 < ../patches/cypress/brcmfmac/0103-brcmfmac-don-t-allow-arp-nd-offload-to-be-enabled-if.patch
		patch -p1 < ../patches/cypress/brcmfmac/0104-brcmfmac-fix-permanent-MAC-address-in-wiphy-is-all-z.patch
		patch -p1 < ../patches/cypress/brcmfmac/0105-non-upstream-ignore-FW-BADARG-error-when-removing-no.patch
		patch -p1 < ../patches/cypress/brcmfmac/0106-Revert-brcmfmac-validate-ifp-pointer-in-brcmf_txfina.patch
		patch -p1 < ../patches/cypress/brcmfmac/0107-Revert-brcmfmac-clean-up-iface-mac-descriptor-before.patch
		patch -p1 < ../patches/cypress/brcmfmac/0108-brcmfmac-Support-DPP-feature.patch
		patch -p1 < ../patches/cypress/brcmfmac/0109-brcmfmac-move-firmware-path-to-cypress-folder.patch
		patch -p1 < ../patches/cypress/brcmfmac/0110-brcmfmac-add-support-for-sof-time-stammping-for-tx-p.patch
		patch -p1 < ../patches/cypress/brcmfmac/0111-Revert-brcmfmac-add-support-for-CYW89359-SDIO-chipse.patch
		patch -p1 < ../patches/cypress/brcmfmac/0112-brcmfmac-initialize-the-requested-dwell-time.patch
		patch -p1 < ../patches/cypress/brcmfmac/0113-non-upstream-free-eventmask_msg-after-updating-event.patch

		#v5.4.18-2020_0925
		patch -p1 < ../patches/cypress/brcmfmac/0114-brcmfmac-fix-invalid-address-access-when-enabling-SC.patch
		patch -p1 < ../patches/cypress/brcmfmac/0115-brcmfmac-calling-brcmf_free-when-removing-SDIO-devic.patch
		patch -p1 < ../patches/cypress/brcmfmac/0116-brcmfmac-add-a-timer-to-read-console-periodically-in.patch
		patch -p1 < ../patches/cypress/brcmfmac/0117-brcmfmac-return-error-when-getting-invalid-max_flowr.patch
		patch -p1 < ../patches/cypress/brcmfmac/0118-brcmfmac-Fix-to-add-skb-free-for-TIM-update-info-whe.patch
		patch -p1 < ../patches/cypress/brcmfmac/0119-brcmfmac-Fix-to-add-brcmf_clear_assoc_ies-when-rmmod.patch
		patch -p1 < ../patches/cypress/brcmfmac/0120-brcmfmac-dump-dongle-memory-when-attaching-failed.patch
		patch -p1 < ../patches/cypress/brcmfmac/0121-brcmfmac-update-address-mode-via-test-tool-for-AP-mo.patch
		patch -p1 < ../patches/cypress/brcmfmac/0122-brcmfmac-load-54591-firmware-for-chip-ID-0x4355.patch
		patch -p1 < ../patches/cypress/brcmfmac/0123-brcmfmac-reserve-tx-credit-only-when-txctl-is-ready-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0124-brcmfmac-Fix-interoperating-DPP-and-other-encryption.patch
		patch -p1 < ../patches/cypress/brcmfmac/0125-brcmfmac-fix-SDIO-bus-errors-during-high-temp-tests.patch
		patch -p1 < ../patches/cypress/brcmfmac/0126-brcmfmac-Add-dump_survey-cfg80211-ops-for-HostApd-Au.patch
		patch -p1 < ../patches/cypress/brcmfmac/0127-brcmfmac-Fix-warning-message-after-dongle-setup-fail.patch
		patch -p1 < ../patches/cypress/brcmfmac/0128-revert-brcmfmac-set-state-of-hanger-slot-to-FREE-whe.patch
		patch -p1 < ../patches/cypress/brcmfmac/0129-brcmfmac-Fix-warning-when-hitting-FW-crash-with-flow.patch

		#v5.4.18-2021_0114
		patch -p1 < ../patches/cypress/brcmfmac/0130-brcmfmac-correctly-remove-all-p2p-vif.patch
		patch -p1 < ../patches/cypress/brcmfmac/0131-brcmfmac-use-firmware_request_nowarn-for-the-board-s.patch
		patch -p1 < ../patches/cypress/brcmfmac/0132-brcmfmac-fix-firmware-trap-while-dumping-obss-stats.patch
		patch -p1 < ../patches/cypress/brcmfmac/0133-brcmfmac-add-creating-station-interface-support.patch
		patch -p1 < ../patches/cypress/brcmfmac/0134-brcmfmac-support-station-interface-creation-version-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0135-brcmfmac-To-fix-crash-when-platform-does-not-contain.patch
		patch -p1 < ../patches/cypress/brcmfmac/0136-brcmfmac-Remove-the-call-to-dtim_assoc-IOVAR.patch
		patch -p1 < ../patches/cypress/brcmfmac/0137-brcmfmac-fix-CERT-P2P-5.1.10-failure.patch
		patch -p1 < ../patches/cypress/brcmfmac/0138-brcmfmac-Fix-for-when-connect-request-is-not-success.patch

		#v5.4.18-2021_0527
		patch -p1 < ../patches/cypress/brcmfmac/0139-brcmfmac-Avoiding-Connection-delay.patch
		patch -p1 < ../patches/cypress/brcmfmac/0140-non-upstream-Revert-brcm80211-select-WANT_DEV_COREDU.patch
		patch -p1 < ../patches/cypress/brcmfmac/0141-brcmfmac-Fix-connecting-enterprise-AP-failure.patch
		patch -p1 < ../patches/cypress/brcmfmac/0142-brcmfmac-Fix-for-skbuf-allocation-failure-in-memory-.patch
		patch -p1 < ../patches/cypress/brcmfmac/0143-brcmfmac-Update-SSID-of-hidden-AP-while-informing-it.patch
		patch -p1 < ../patches/cypress/brcmfmac/0144-brcmfmac-Fix-PCIE-suspend-resume-issue.patch
		patch -p1 < ../patches/cypress/brcmfmac/0145-brcmfmac-disable-mpc-when-power_save-is-disabled.patch
		patch -p1 < ../patches/cypress/brcmfmac/0146-brcmfmac-Fix-authentication-latency-caused-by-OBSS-s.patch
		patch -p1 < ../patches/cypress/brcmfmac/0147-brcmfmac-support-external-SAE-authentication-in-stat.patch
		patch -p1 < ../patches/cypress/brcmfmac/0148-brcmfmac-fix-sdio-watchdog-timer-start-fail-issue.patch
		patch -p1 < ../patches/cypress/brcmfmac/0149-brcmfmac-Frameburst-vendor-command-addition.patch

		#exit 2

		${git_bin} add .
		${git_bin} commit -a -m "cypress fmac patchset" -m "v5.4.18-2021_0527" -s
		${git_bin} format-patch -1 -o ../patches/cypress/

	#	exit 2
	#else
		patch_backports
	fi

	#dir 'cypress'
	#exit 2
	#dir 'cypress/fixes'
}

reverts () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	## notes
	##git revert --no-edit xyz -s

	dir 'reverts'

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=1
		cleanup
	fi
}

drivers () {
	#https://github.com/raspberrypi/linux/branches
	#exit 2
	dir 'RPi'
	dir 'drivers/ar1021_i2c'
	dir 'drivers/sound'
	dir 'drivers/spi'
	dir 'drivers/tps65217'

	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/gpio'
#	dir 'drivers/ti/mmc'
	dir 'drivers/greybus'
	dir 'drivers/bluetooth'
}

soc () {
	dir 'bootup_hacks'
}

fixes () {
	dir 'fixes/gcc'
}

###
backports
#reverts
drivers
soc
fixes

packaging () {
	echo "Update: package scripts"
	do_backport="enable"
	if [ "x${do_backport}" = "xenable" ] ; then
		backport_tag="v5.10.88"

		subsystem="bindeb-pkg"
		#regenerate="enable"
		if [ "x${regenerate}" = "xenable" ] ; then
			pre_backports

			cp -v ~/linux-src/scripts/package/* ./scripts/package/

			post_backports
			exit 2
		else
			patch_backports
		fi
	fi
	${git} "${DIR}/patches/backports/bindeb-pkg/0002-builddeb-Install-our-dtbs-under-boot-dtbs-version.patch"
}

packaging
echo "patch.sh ran successfully"
#
