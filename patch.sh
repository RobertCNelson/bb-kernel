#!/bin/bash -e
#
# Copyright (c) 2009-2019 Robert Nelson <robertcnelson@gmail.com>
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
	aufs_prefix="aufs4-"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		KERNEL_REL=4.14.73+
		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}kbuild.patch
		patch -p1 < ${aufs_prefix}kbuild.patch || aufs_fail
		rm -rf ${aufs_prefix}kbuild.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}base.patch
		patch -p1 < ${aufs_prefix}base.patch || aufs_fail
		rm -rf ${aufs_prefix}base.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-base' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}mmap.patch
		patch -p1 < ${aufs_prefix}mmap.patch || aufs_fail
		rm -rf ${aufs_prefix}mmap.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/${aufs_prefix}standalone/aufs${KERNEL_REL}/${aufs_prefix}standalone.patch
		patch -p1 < ${aufs_prefix}standalone.patch || aufs_fail
		rm -rf ${aufs_prefix}standalone.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs-standalone' -s

		${git_bin} format-patch -4 -o ../patches/aufs/

		cd ../
		if [ ! -d ./${aufs_prefix}standalone ] ; then
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/${aufs_prefix}standalone --depth=1
			cd ./${aufs_prefix}standalone/
				aufs_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./${aufs_prefix}standalone || true
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/${aufs_prefix}standalone --depth=1
			cd ./${aufs_prefix}standalone/
				aufs_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/
		KERNEL_REL=4.14

		cp -v ../${aufs_prefix}standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../${aufs_prefix}standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../${aufs_prefix}standalone/fs/aufs/* ./fs/aufs/
		cp -v ../${aufs_prefix}standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs' -m "https://github.com/sfjro/${aufs_prefix}standalone/commit/${aufs_hash}" -s
		${git_bin} format-patch -5 -o ../patches/aufs/
		echo "AUFS: https://github.com/sfjro/${aufs_prefix}standalone/commit/${aufs_hash}" > ../patches/git/AUFS

		rm -rf ../${aufs_prefix}standalone/ || true

		${git_bin} reset --hard HEAD~5

		start_cleanup

		${git} "${DIR}/patches/aufs/0001-merge-aufs-kbuild.patch"
		${git} "${DIR}/patches/aufs/0002-merge-aufs-base.patch"
		${git} "${DIR}/patches/aufs/0003-merge-aufs-mmap.patch"
		${git} "${DIR}/patches/aufs/0004-merge-aufs-standalone.patch"
		${git} "${DIR}/patches/aufs/0005-merge-aufs.patch"

		wdir="aufs"
		number=5
		cleanup
	fi

	dir 'aufs'
}

can_isotp () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./can-isotp ] ; then
			${git_bin} clone https://github.com/hartkopp/can-isotp --depth=1
			cd ./can-isotp
				isotp_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./can-isotp || true
			${git_bin} clone https://github.com/hartkopp/can-isotp --depth=1
			cd ./can-isotp
				isotp_hash=$(git rev-parse HEAD)
			cd -
		fi

		cd ./KERNEL/

		cp -v ../can-isotp/include/uapi/linux/can/isotp.h  include/uapi/linux/can/
		cp -v ../can-isotp/net/can/isotp.c net/can/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: can-isotp: https://github.com/hartkopp/can-isotp' -m "https://github.com/hartkopp/can-isotp/commit/${isotp_hash}" -s
		${git_bin} format-patch -1 -o ../patches/can_isotp/
		echo "CAN-ISOTP: https://github.com/hartkopp/can-isotp/commit/${isotp_hash}" > ../patches/git/CAN-ISOTP

		rm -rf ../can-isotp/ || true

		${git_bin} reset --hard HEAD~1

		start_cleanup

		${git} "${DIR}/patches/can_isotp/0001-merge-can-isotp-https-github.com-hartkopp-can-isotp.patch"

		wdir="can_isotp"
		number=1
		cleanup

		exit 2
	fi
	dir 'can_isotp'
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	rt_patch="${KERNEL_REL}${kernel_rt}"

	#v4.14.x
	#${git_bin} revert --no-edit xyz

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -m "patch-${rt_patch}.patch.xz" -s
		${git_bin} format-patch -1 -o ../patches/rt/
		echo "RT: patch-${rt_patch}.patch.xz" > ../patches/git/RT

		exit 2
	fi

	dir 'rt'
}

backport_brcm80211 () {
	echo "dir: brcm80211"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./brcm80211 ] ; then
			${git_bin} clone -b rpi-4.14.y https://github.com/raspberrypi/linux brcm80211 --depth=1 --reference ./KERNEL/
		else
			rm -rf ./brcm80211 || true
			${git_bin} clone -b rpi-4.14.y https://github.com/raspberrypi/linux brcm80211 --depth=1 --reference ./KERNEL/
		fi
		cd ./KERNEL/

		cp -rv ../brcm80211/drivers/net/wireless/broadcom/brcm80211/ ./drivers/net/wireless/broadcom/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: brcm80211' -s
		${git_bin} format-patch -1 -o ../patches/brcm80211/

		rm -rf ../brcm80211/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/brcm80211/0001-merge-brcm80211.patch"

		wdir="brcm80211"
		number=1
		cleanup
	fi

	${git} "${DIR}/patches/brcm80211/0001-merge-brcm80211.patch"
}

wireguard_fail () {
	echo "WireGuard failed"
	exit 2
}

wireguard () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./WireGuard ] ; then
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
			cd ./WireGuard
				wireguard_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./WireGuard || true
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
			cd ./WireGuard
				wireguard_hash=$(git rev-parse HEAD)
			cd -
		fi

		#cd ./WireGuard/
		#${git_bin}  revert --no-edit xyz
		#cd ../

		cd ./KERNEL/

		../WireGuard/contrib/kernel-tree/create-patch.sh | patch -p1 || wireguard_fail

		${git_bin} add .
		${git_bin} commit -a -m 'merge: WireGuard' -m "https://git.zx2c4.com/WireGuard/commit/${wireguard_hash}" -s
		${git_bin} format-patch -1 -o ../patches/WireGuard/
		echo "WIREGUARD: https://git.zx2c4.com/WireGuard/commit/${wireguard_hash}" > ../patches/git/WIREGUARD

		rm -rf ../WireGuard/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"

		wdir="WireGuard"
		number=1
		cleanup
	fi

	dir 'WireGuard'
}

ti_pm_firmware () {
	#http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=shortlog;h=refs/heads/ti-v4.1.y-next
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ ! -d ./ti-amx3-cm3-pm-firmware ] ; then
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
			cd ./ti-amx3-cm3-pm-firmware
				ti_amx3_cm3_hash=$(git rev-parse HEAD)
			cd -
		else
			rm -rf ./ti-amx3-cm3-pm-firmware || true
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
			cd ./ti-amx3-cm3-pm-firmware
				ti_amx3_cm3_hash=$(git rev-parse HEAD)
			cd -
		fi
		cd ./KERNEL/

		mkdir -p ./firmware/ || true
		cp -v ../ti-amx3-cm3-pm-firmware/bin/am* ./firmware/

		${git_bin} add -f ./firmware/am*
		${git_bin} commit -a -m 'Add AM335x CM3 Power Managment Firmware' -m "http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" -s
		${git_bin} format-patch -1 -o ../patches/drivers/ti/firmware/
		echo "TI_AMX3_CM3: http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=commit;h=${ti_amx3_cm3_hash}" > ../patches/git/TI_AMX3_CM3

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

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
aufs
can_isotp
rt
backport_brcm80211
#wireguard
ti_pm_firmware
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
	backport_tag="v4.19.96"

	subsystem="greybus"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		cp -rv ~/linux-src/drivers/staging/greybus/* ./drivers/staging/greybus/

		post_backports
		exit 2
	else
		patch_backports
		${git} "${DIR}/patches/backports/greybus/0002-greybus-drivers-staging-greybus-module.c-no-struct_s.patch"
	fi
}

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#https://github.com/torvalds/linux/commit/00f0ea70d2b82b7d7afeb1bdedc9169eb8ea6675
	#
	#Causes bone_capemgr to get stuck on slot 1 and just eventually exit "without" checking slot2/3/4...
	#
	#[    5.406775] bone_capemgr bone_capemgr: Baseboard: 'A335BNLT,00C0,2516BBBK2626'
	#[    5.414178] bone_capemgr bone_capemgr: compatible-baseboard=ti,beaglebone-black - #slots=4
	#[    5.422573] bone_capemgr bone_capemgr: Failed to add slot #1

	${git} "${DIR}/patches/reverts/0001-Revert-eeprom-at24-check-if-the-chip-is-functional-i.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=1
		cleanup
	fi
}

drivers () {
	dir 'drivers/ar1021_i2c'
	dir 'drivers/btrfs'
	dir 'drivers/pwm'
	dir 'drivers/spi'
	dir 'drivers/ssd1306'
	dir 'drivers/tps65217'
	dir 'drivers/opp'
	dir 'drivers/wiznet'

	#https://github.com/pantoniou/linux-beagle-track-mainline/tree/bbb-overlays
	echo "dir: drivers/ti/bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0001-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0002-add-PM-firmware.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0003-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0004-omap-Fix-crash-when-omap-device-is-disabled.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0005-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0006-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0007-of-overlay-kobjectify-overlay-objects.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0008-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0009-Documentation-ABI-overlays-global-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0010-Documentation-document-of_overlay_disable-parameter.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0011-of-overlay-add-per-overlay-sysfs-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0012-Documentation-ABI-overlays-per-overlay-docs.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0013-of-dynamic-Add-__of_node_dupv.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0014-of-changesets-Introduce-changeset-helper-methods.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0015-of-changeset-Add-of_changeset_node_move-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0016-of-unittest-changeset-helpers.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0017-OF-DT-Overlay-configfs-interface-v7.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0018-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0019-misc-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0020-doc-misc-Beaglebone-capemanager-documentation.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0021-doc-dt-beaglebone-cape-manager-bindings.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0022-doc-ABI-bone_capemgr-sysfs-API.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0023-MAINTAINERS-Beaglebone-capemanager-maintainer.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0024-arm-dts-Enable-beaglebone-cape-manager.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0025-of-overlay-Implement-target-index-support.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0026-of-unittest-Add-indirect-overlay-target-test.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0027-doc-dt-Document-the-indirect-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0028-of-overlay-Introduce-target-root-capability.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0029-of-unittest-Unit-tests-for-target-root-overlays.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0030-doc-dt-Document-the-target-root-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0031-RFC-Device-overlay-manager-PCI-USB-DT.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0032-of-rename-_node_sysfs-to-_node_post.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0033-of-Support-hashtable-lookups-for-phandles.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0034-of-unittest-hashed-phandles-unitest.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0035-of-overlay-Pick-up-label-symbols-from-overlays.patch"


	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0036-of-Portable-Device-Tree-connector.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0037-boneblack-defconfig.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0038-bone_capemgr-uboot_capemgr_enabled-flag.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0039-bone_capemgr-kill-with-uboot-flag.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0040-fix-include-linux-of.h-add-linux-slab.h-include.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="drivers/ti/bbb_overlays"
		number=40
		cleanup
	fi

	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/etnaviv'
	dir 'drivers/ti/eqep'
	dir 'drivers/ti/mcasp'
	dir 'drivers/ti/rpmsg'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/spi'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/uio'
	dir 'drivers/ti/gpio'
	dir 'drivers/greybus'
}

soc () {
#	dir 'soc/exynos'
#	dir 'soc/imx/udoo'
#	dir 'soc/imx/wandboard'
#	dir 'soc/imx'
	dir 'soc/ti'
	dir 'soc/ti/bone_common'
	dir 'soc/ti/uboot'
	dir 'soc/ti/blue'
	dir 'soc/ti/sancloud'
	dir 'soc/ti/abbbi'
	dir 'soc/ti/am335x_olimex_som'
	dir 'soc/ti/beaglebone_capes'
	dir 'soc/ti/pocketbeagle'
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beaglebone () {
	#This has to be last...
	echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	####
	#dtb makefile
	echo "dir: beaglebone/generated"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append

#		device="am335x-boneblack-roboticscape.dtb" ; dtb_makefile_append
#		device="am335x-boneblack-wireless-roboticscape.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe.dtb" ; dtb_makefile_append

		device="am335x-abbbi.dtb" ; dtb_makefile_append

		device="am335x-olimex-som.dtb" ; dtb_makefile_append

		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append

		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-pocketbeagle.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
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
	${git} "${DIR}/patches/sgx/0003-ARM-OMAP2-Use-pdata-quirks-for-sgx-deassert_hardrese.patch"
	${git} "${DIR}/patches/sgx/0004-ARM-dts-am33xx-add-DT-node-for-gpu.patch"
	${git} "${DIR}/patches/sgx/0005-Revert-ARM-reduce-visibility-of-dmac_-functions.patch"
	${git} "${DIR}/patches/sgx/0006-arm-Export-cache-flush-management-symbols-when-MULTI.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="sgx"
		number=6
		cleanup
	fi
}

###
backports
reverts
drivers
soc
beaglebone
#dir 'fixes'
dir 'drivers/ti/spi_symlink'
sgx

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/Makefile" "${DIR}/KERNEL/scripts/package"
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		#Needed for v4.11.x and less
		#patch -p1 < "${DIR}/patches/packaging/0002-Revert-deb-pkg-Remove-the-KBUILD_IMAGE-workaround.patch"
		${git_bin} commit -a -m 'packaging: sync builddeb changes' -s
		${git_bin} format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

packaging
echo "patch.sh ran successfully"
