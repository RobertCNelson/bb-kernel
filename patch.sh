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

aufs_fail () {
	echo "aufs failed"
	exit 2
}

aufs () {
	#https://github.com/sfjro/aufs-standalone/tree/aufs5.15.41
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		KERNEL_REL=5.15.41
		wget https://raw.githubusercontent.com/sfjro/aufs-standalone/aufs${KERNEL_REL}/aufs5-kbuild.patch
		patch -p1 < aufs5-kbuild.patch || aufs_fail
		rm -rf aufs5-kbuild.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/aufs-standalone/aufs${KERNEL_REL}/aufs5-base.patch
		patch -p1 < aufs5-base.patch || aufs_fail
		rm -rf aufs5-base.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-base' -s

		wget https://raw.githubusercontent.com/sfjro/aufs-standalone/aufs${KERNEL_REL}/aufs5-mmap.patch
		patch -p1 < aufs5-mmap.patch || aufs_fail
		rm -rf aufs5-mmap.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/aufs-standalone/aufs${KERNEL_REL}/aufs5-standalone.patch
		patch -p1 < aufs5-standalone.patch || aufs_fail
		rm -rf aufs5-standalone.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-standalone' -s

		${git_bin} format-patch -4 -o ../patches/external/aufs/

		cd ../
		if [ -d ./aufs-standalone ] ; then
			rm -rf ./aufs-standalone || true
		fi

		${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/aufs-standalone --depth=1
		cd ./aufs-standalone/
			aufs_hash=$(git rev-parse HEAD)
		cd -

		cd ./KERNEL/
		KERNEL_REL=5.15

		cp -v ../aufs-standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../aufs-standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../aufs-standalone/fs/aufs/* ./fs/aufs/
		cp -v ../aufs-standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs' -m "https://github.com/sfjro/aufs-standalone/commit/${aufs_hash}" -s

		${git_bin} format-patch -5 -o ../patches/external/aufs/
		echo "AUFS: https://github.com/sfjro/aufs-standalone/commit/${aufs_hash}" > ../patches/external/git/AUFS

		rm -rf ../aufs-standalone/ || true

		${git_bin} reset --hard HEAD~5

		start_cleanup

		${git} "${DIR}/patches/external/aufs/0001-merge-aufs-kbuild.patch"
		${git} "${DIR}/patches/external/aufs/0002-merge-aufs-base.patch"
		${git} "${DIR}/patches/external/aufs/0003-merge-aufs-mmap.patch"
		${git} "${DIR}/patches/external/aufs/0004-merge-aufs-standalone.patch"
		${git} "${DIR}/patches/external/aufs/0005-merge-aufs.patch"

		wdir="external/aufs"
		number=5
		cleanup
	fi
	dir 'external/aufs'
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
	branch="v5.15.x"
	https_repo="https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees.git"
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

		device="am335x-bonegreen-gateway.dtb" ; dtb_makefile_append

		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append

		${git_bin} add -f arch/arm/boot/dts/
		${git_bin} add -f include/dt-bindings/
		${git_bin} commit -a -m "Add BeagleBoard.org Device Tree Changes" -m "https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/tree/${branch}" -m "https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/commit/${git_hash}" -s
		${git_bin} format-patch -1 -o ../patches/soc/ti/beagleboard_dtbs/
		echo "BBDTBS: https://git.beagleboard.org/beagleboard/BeagleBoard-DeviceTrees/-/commit/${git_hash}" > ../patches/external/git/BBDTBS

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
aufs
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

patch_backports () {
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

backports () {
	backport_tag="v5.10.186"

	subsystem="uio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/uio/uio_pruss.c ./drivers/uio/

		post_backports
		exit 2
	else
		patch_backports
		dir 'drivers/ti/uio'
	fi

	backport_tag="v5.15.120"

	subsystem="iio"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/include/linux/iio/* ./include/linux/iio/
		cp -rv ~/linux-src/include/uapi/linux/iio/* ./include/uapi/linux/iio/
		cp -rv ~/linux-src/drivers/iio/* ./drivers/iio/
		cp -rv ~/linux-src/drivers/staging/iio/* ./drivers/staging/iio/

		post_backports
		exit 2
	#else
		patch_backports
	fi

	backport_tag="v5.19.17"

	subsystem="it66121"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -v ~/linux-src/drivers/gpu/drm/bridge/ite-it66121.c ./drivers/gpu/drm/bridge/

		post_backports
		exit 2
	else
		patch_backports
	fi
}

brcmfmac () {
	#https://git.beagleboard.org/RobertCNelson/cypress-linux-wifi-driver-release
	backport_tag="v5.15.58"

	subsystem="brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/net/wireless/broadcom/brcm80211/* ./drivers/net/wireless/broadcom/brcm80211/
		cp -rv ~/linux-src/net/mac80211/* ./net/mac80211/
		cp -rv ~/linux-src/net/wireless/* ./net/wireless/
		#cp -v ~/linux-src/include/linux/mmc/sdio_ids.h ./include/linux/mmc/sdio_ids.h
		#cp -v ~/linux-src/include/net/cfg80211.h ./include/net/cfg80211.h
		#cp -v ~/linux-src/include/uapi/linux/nl80211.h ./include/uapi/linux/nl80211.h
		#cp -v ~/linux-src/include/linux/firmware.h ./include/linux/firmware.h

		post_backports
		#v5.15.58-2023_0523

		patch -p1 < ../patches/external/cypress/brcmfmac/0001-non-upstream-add-sg-parameters-dts-parsing.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0002-brcmfmac-support-AP-isolation.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0003-non-upstream-make-firmware-eap_restrict-a-module-par.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0004-non-upstream-support-wake-on-ping-packet.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0005-non-upstream-remove-WOWL-configuration-in-disconnect.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0006-non-upstream-make-setting-SDIO-workqueue-WQ_HIGHPRI-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0007-non-upstream-avoid-network-disconnection-during-susp.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0008-non-upstream-Changes-to-improve-USB-Tx-throughput.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0009-brcmfmac-introduce-module-parameter-to-configure-def.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0010-non-upstream-configure-wowl-parameters-in-suspend-fu.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0011-non-upstream-disable-command-decode-in-sdio_aos-for-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0012-brcmfmac-increase-default-max-WOWL-patterns-to-16.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0013-non-upstream-Enable-Process-and-forward-PHY_TEMP-eve.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0014-non-upstream-fix-continuous-802.1x-tx-pending-timeou.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0015-non-upstream-add-sleep-in-bus-suspend-and-cfg80211-r.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0016-brcmfmac-add-CYW43570-PCIE-device.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0017-non-upstream-fix-scheduling-while-atomic-issue-when-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0018-brcmfmac-Support-89459-pcie.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0019-brcmfmac-Support-multiple-AP-interfaces-and-fix-STA-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0020-non-upstream-Support-custom-PCIE-BAR-window-size.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0021-brcmfmac-support-for-virtual-interface-creation-from.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0022-brcmfmac-increase-dcmd-maximum-buffer-size.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0023-brcmfmac-set-net-carrier-on-via-test-tool-for-AP-mod.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0024-nl80211-add-authorized-flag-back-to-ROAM-event.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0025-brcmfmac-set-authorized-flag-in-ROAM-event-for-offlo.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0026-brcmfmac-set-authorized-flag-in-ROAM-event-for-PMK-c.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0027-nl80211-add-authorized-flag-to-CONNECT-event.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0028-brcmfmac-set-authorized-flag-in-CONNECT-event-for-PM.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0029-brcmfmac-add-support-for-Opportunistic-Key-Caching.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0030-brcmfmac-To-support-printing-USB-console-messages.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0031-non-upstream-Fix-no-P2P-IE-in-probe-requests-issue.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0032-brcmfmac-add-54591-PCIE-device.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0033-non-upstream-support-DS1-exit-firmware-re-download.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0034-non-upstream-fix-43012-insmod-after-rmmod-in-DS1-fai.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0035-non-upstream-fix-43012-driver-reload-failure-after-D.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0036-brcmfmac-reset-PMU-backplane-all-cores-in-CYW4373-du.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0037-non-upstream-calling-skb_orphan-before-sending-skb-t.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0038-non-upstream-workaround-for-4373-USB-WMM-5.2.27-test.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0039-non-upstream-disable-command-decode-in-sdio_aos-for-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0040-non-upstream-disable-command-decode-in-sdio_aos-for-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0041-non-upstream-disable-command-decode-in-sdio_aos-for-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0042-brcmfmac-support-the-forwarding-packet.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0043-brcmfmac-add-a-variable-for-packet-forwarding-condit.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0044-brcmfmac-don-t-allow-arp-nd-offload-to-be-enabled-if.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0045-non-upstream-ignore-FW-BADARG-error-when-removing-no.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0046-brcmfmac-Support-DPP-feature.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0047-brcmfmac-move-firmware-path-to-cypress-folder.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0048-brcmfmac-add-support-for-sof-time-stammping-for-tx-p.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0049-non-upstream-free-eventmask_msg-after-updating-event.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0050-brcmfmac-fix-invalid-address-access-when-enabling-SC.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0051-brcmfmac-add-a-timer-to-read-console-periodically-in.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0052-brcmfmac-return-error-when-getting-invalid-max_flowr.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0053-brcmfmac-Fix-to-add-skb-free-for-TIM-update-info-whe.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0054-brcmfmac-Fix-to-add-brcmf_clear_assoc_ies-when-rmmod.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0055-brcmfmac-dump-dongle-memory-when-attaching-failed.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0056-brcmfmac-update-address-mode-via-test-tool-for-AP-mo.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0057-brcmfmac-load-54591-firmware-for-chip-ID-0x4355.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0058-brcmfmac-Fix-interoperating-DPP-and-other-encryption.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0059-brcmfmac-fix-SDIO-bus-errors-during-high-temp-tests.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0060-brcmfmac-Add-dump_survey-cfg80211-ops-for-HostApd-Au.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0061-revert-brcmfmac-set-state-of-hanger-slot-to-FREE-whe.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0062-brcmfmac-correctly-remove-all-p2p-vif.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0063-brcmfmac-fix-firmware-trap-while-dumping-obss-stats.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0064-brcmfmac-add-creating-station-interface-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0065-brcmfmac-support-station-interface-creation-version-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0066-brcmfmac-To-fix-crash-when-platform-does-not-contain.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0067-brcmfmac-Remove-the-call-to-dtim_assoc-IOVAR.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0068-brcmfmac-fix-CERT-P2P-5.1.10-failure.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0069-brcmfmac-Fix-for-when-connect-request-is-not-success.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0070-brcmfmac-Avoiding-Connection-delay.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0071-non-upstream-Revert-brcm80211-select-WANT_DEV_COREDU.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0072-brcmfmac-Fix-connecting-enterprise-AP-failure.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0073-brcmfmac-Fix-for-skbuf-allocation-failure-in-memory-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0074-brcmfmac-Update-SSID-of-hidden-AP-while-informing-it.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0075-brcmfmac-Fix-PCIE-suspend-resume-issue.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0076-brcmfmac-disable-mpc-when-power_save-is-disabled.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0077-brcmfmac-Fix-authentication-latency-caused-by-OBSS-s.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0078-brcmfmac-support-external-SAE-authentication-in-stat.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0079-brcmfmac-fix-sdio-watchdog-timer-start-fail-issue.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0080-brcmfmac-Frameburst-vendor-command-addition.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0081-brcmfmac-add-support-for-CYW43439-SDIO-chipset.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0082-brcmfmac-add-BT-shared-SDIO-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0083-brcmfmac-add-CYW43439-SR-related-changes.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0084-brcmfmac-add-support-for-CYW43439-with-blank-OTP.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0085-brcmfmac-support-43439-Cypress-Vendor-and-Device-ID.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0086-brcmfmac-fix-P2P-device-discovery-failure.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0087-brcmfmac-Add-SDIO-verdor-device-id-for-CYW89459-in-h.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0088-brcmfmac-Add-CYW89459-HW-ID-and-modify-sdio-F2-block.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0089-brcmfmac-Fix-AP-interface-delete-issue.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0090-brcmfmac-Revise-channel-info-for-WPA3-external-SAE.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0091-brcmfmac-Fix-structure-size-for-WPA3-external-SAE.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0092-brcmfmac-support-54590-54594-PCIe-device-id.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0093-Revert-non-upstream-make-setting-SDIO-workqueue-WQ_H.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0094-brcmfmac-Set-SDIO-workqueue-as-WQ_HIGHPRI.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0095-brcmfmac-revise-SoftAP-channel-setting.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0096-brcmfmac-Optimize-CYW4373-SDIO-current.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0097-brcmfmac-use-request_firmware_direct-for-loading-boa.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0098-brcmfmac-enable-pmk-catching-for-ext-sae-wpa3-ap.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0099-brcmfmac-fixes-CYW4373-SDIO-CMD53-error.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0100-brcmfmac-add-PCIe-mailbox-support-for-core-revision-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0101-brcmfmac-add-support-for-TRX-firmware-download.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0102-brcmfmac-add-Cypress-PCIe-vendor-ID.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0103-brcmfmac-add-support-for-CYW55560-PCIe-chipset.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0104-brcmfmac-add-bootloader-console-buffer-support-for-P.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0105-brcmfmac-support-4373-pcie.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0106-brcmfmac-extsae-supports-SAE-OKC-roam.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0107-nl80211-add-roaming-offload-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0108-brcm80211-add-FT-11r-OKC-roaming-offload-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0109-brcmfmac-support-extsae-with-psk-1x-offloading.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0110-Disable-out-of-band-device-wake-based-DeepSleep-Stat.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0111-brcmfmac-Improve-the-delay-during-scan.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0112-brcmfmac-skip-6G-oob-scan-report.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0113-Revert-brcmfmac-Improve-the-delay-during-scan.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0114-brcmfmac-Improve-the-delay-during-scan.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0115-brcmfmac-add-FW-AP-selection-mod-param.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0116-Changing-info-messages-under-debug-BRCMF_INFO_VAL.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0117-revert-brcmfmac-Set-timeout-value-when-configuring-p.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0118-brcmfmac-fixes-scan-invalid-channel-when-enable-host.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0119-brcmfmac-do-not-disable-controller-in-apmode-stop.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0120-brcmfmac-support-11ax-and-6G-band.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0121-brcmfmac-fixes-invalid-channel-still-in-the-channel-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0122-non-upstream-Fix-lspci-not-enumerating-wifi-device-a.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0123-brcmfmac-support-signal-monitor-feature-for-wpa_supp.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0124-brcmfmac-add-support-for-CYW55560-SDIO-chipset.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0125-brcmfmac-Modified-Kconfig-help-format.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0126-brcmfmac-Fix-incorrect-WARN_ON-causing-set_pmk-failu.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0127-brcmfmac-report-cqm-rssi-event-based-on-rssi-change-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0128-brcmfmac-add-WPA3_AUTH_1X_SUITE_B_SHA384-related-sup.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0129-non-upstream-Handle-the-6G-case-in-the-bw_cap-chansp.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0130-net-brcm80211-Fix-race-on-timer_add-in-wifi-driver.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0131-Remove-WARN_ON-while-no-6g-bw_cap.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0132-brcmfmac-update-the-statically-defined-HE-MAC-PHY-Ca.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0133-brcmfmac-fix-set_pmk-warning-message.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0134-brcmfmac-update-BIP-setting-and-wsec_info-for-GMAC-a.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0135-brcmfmac-send-roam-request-when-supplicant-triggers-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0136-brcmfmac-send-BCNLOST_MSG-event-on-beacon-loss-for-s.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0137-brcmfmac-trying-to-get-GCMP-cap-before-doing-set-it.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0138-brcmfmac-update-firmware-loading-name-for-CY5557x.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0139-brcmfmac-use-SR-core-id-to-decide-SR-capability-for-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0140-brcmfmac-SAP-mode-parsing-sae_h2e-setting-from-beaco.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0141-brcmfmac-add-sanity-check-for-potential-underflow-an.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0142-brcmfmac-Fixing-vulnerability.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0143-brcmfmac-Implementing-set_bitrate_mask-cfg80211-ops-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0144-brcm80211-add-FT-PSK-roaming-offload-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0145-brcmfmac-enable-6G-split-scanning-feature.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0146-brcmfmac-set-HE-6GHz-capabilities-for-bring-up-SAP.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0147-brcmfmac-add-interface-to-set-bsscolor-for-bring-up-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0148-non-upstream-add-IFX-vendor-OUI-file.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0149-non-upstream-adding-vendor_cmds-are-with-IFX_OUI.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0150-brcmfmac-introduce-a-module-parameter-to-disable-the.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0151-brcmfmac-skip-6GHz-capab-registration-with-cfg80211-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0152-brcmfmac-set-HE-rate-only-if-HE-MCS-set-and-valid.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0153-brcmfmac-remove-workaround-cause-the-FW-can-support-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0154-brcmfmac-ext_owe-supporting.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0155-brcmfmac-Avoid-adding-two-sets-of-HE-Capab-and-Oper-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0156-non-upstream-Add-IFX-TWT-Offload-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0157-non-upstream-vendor-cmd-addition-for-wl-he-bsscolor.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0158-non-upstream-vendor-cmd-addition-for-wl-he-muedca_op.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0159-non-upstream-vendor-cmd-addition-for-wl-amsdu.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0160-non-upstream-vendor-cmd-addition-for-wl-ldpc_cap.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0161-non-upstream-Refine-TWT-code-for-checkpatch.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0162-cfg80211-fix-u8-overflow-in-cfg80211_update_notliste.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0163-cfg80211-mac80211-reject-bad-MBSSID-elements.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0164-cfg80211-fix-BSS-refcounting-bugs.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0165-cfg80211-avoid-nontransmitted-BSS-list-corruption.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0166-brcmfmac-Fix-potential-buffer-overflow-in-brcmf_fweh.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0167-non-upstream-vendor-cmd-addition-for-wl-oce-enable.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0168-non-upstream-vendor-cmd-addition-for-wl-randmac.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0169-brcmfmac-compile-warning-fix.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0170-Fix-invalid-RAM-address-warning-for-PCIE-platforms.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0171-brcmfmac-Fix-dpp-very-low-tput-issue.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0172-non-upstream-keep-IFX-license-header-for-non-upstrea.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0173-non-upstream-internal-sup-uses-join-command-to-send-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0174-non-upstream-Supporting-IFX_vendor-commands-of-MBO.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0175-brcmfmac-Set-corresponding-cqm-event-handlers-based-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0176-non-upstream-isolate-power_save-off-and-mpc-0.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0177-brcmfmac-Add-NULL-checks-to-fix-multiple-NULL-pointe.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0178-brcmfmac-fix-compiler-error.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0179-non-upstream-supporting-giartrx-IFX-vendor-ID.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0180-wireless-brcmfmac-Use-netif_rx.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0181-brcmfmac-replace-SDIO-function-number-with-definitio.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0182-brcmfmac-move-SDIO-function-number-definition-to-sdi.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0183-Restore-channel-info.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0184-brcmfmac-Avoid-adding-two-sets-of-HE-Capab-and-Oper-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0185-non-upstream-sdio-t-put-tuning.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0186-brcmfmac-get-chip-info-from-SDIOD-if-chip-common-spa.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0187-non-upstream-vendor-cmd-addition-for-wpa_cli-wnm_max.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0188-Resolve-skb-alloc-failures-in-FMAC.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0189-non-upstream-sdio-t-put-tuning.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0190-Fix-a-NULL-pointer-dereference.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0191-brcmfmac-add-protection-for-PCIe-Read-Write-out-of-b.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0192-Added-DSCP-to-WMM-UP-mapping.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0193-brcmfmac-fix-mac-address-is-not-assigned-for-iovar-B.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0194-non-upstream-fixing-compile-error-on-kernel-5.9-onwa.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0195-brcmfmac-fix-for-guard-interval-for-iw-set-bitrates.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0196-brcmfmac-Add-support-for-ethtool-packet-statistics.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0197-brcmfmac-Add-55500-chip-support.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0198-brcmfmac-SDIO-Rev31-changes-in-rmmod-sequence.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0199-brcmfmac-Wait-for-bootloader-ready-before-doing-back.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0200-brcmfmac-prevent-double-free-on-hardware-reset.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0201-brcmfmac-Update-D2H-Validation-Done-Timeout.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0202-brcmfmac-SR-in-not-getting-enabled-in-H1.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0203-brcmfmac-set-up-wrong-status-when-use-internal-suppl.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0204-brcmfmac-TWT-Add-a-new-feature-source-header-file-fo.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0205-brcmfmac-TWT-Add-support-to-handle-the-async-TWT-eve.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0206-brcmfmac-TWT-create-a-debugfs-file-to-expose-the-TWT.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0207-nl80211-Update-IFX-NL80211-Vendor-source-and-header-.patch
		patch -p1 < ../patches/external/cypress/brcmfmac/0208-brcmfmac-add-protection-for-firmware-doesn-t-have-ex.patch
		#exit 2

		${git_bin} add .
		${git_bin} commit -a -m "cypress fmac patchset" -m "v5.15.58-2023_0523" -s
		${git_bin} format-patch -1 -o ../patches/external/cypress/

		exit 2
	else
		patch_backports
	fi
	dir 'external/cypress'
}

drivers () {
	#https://github.com/raspberrypi/linux/branches
	#exit 2
	dir 'RPi'
	dir 'boris'
	dir 'drivers/ar1021_i2c'
	dir 'drivers/spi'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/gpio'
	dir 'drivers/greybus'
	dir 'drivers/serdev'
	dir 'drivers/fb_ssd1306'
	dir 'drivers/mikrobus'
	dir 'bootup_hacks'
}

###
backports
#brcmfmac
drivers

packaging () {
	#do_backport="enable"
	if [ "x${do_backport}" = "xenable" ] ; then
		backport_tag="v5.18.19"

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
