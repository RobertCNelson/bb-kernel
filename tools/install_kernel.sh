#!/bin/sh -e
#
# Copyright (c) 2009-2015 Robert Nelson <robertcnelson@gmail.com>
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

unset KERNEL_UTS
unset MMC

DIR=$PWD

. "${DIR}/../version.sh"

mmc_write_rootfs () {
	echo "Installing ${KERNEL_UTS}-modules.tar.gz to ${partition}"

	if [ -d "${location}/lib/modules/${KERNEL_UTS}" ] ; then
		sudo rm -rf "${location}/lib/modules/${KERNEL_UTS}" || true
	fi

	sudo tar ${UNTAR} "${DIR}/deploy/${KERNEL_UTS}-modules.tar.gz" -C "${location}/"
	sync

	if [ -f "${DIR}/deploy/config-${KERNEL_UTS}" ] ; then
		if [ -f "${location}/boot/config-${KERNEL_UTS}" ] ; then
			sudo rm -f "${location}/boot/config-${KERNEL_UTS}" || true
		fi
		sudo cp -v "${DIR}/deploy/config-${KERNEL_UTS}" "${location}/boot/config-${KERNEL_UTS}"
		sync
	fi
	echo "info: [${KERNEL_UTS}] now installed..."
}

mmc_write_boot_pre () {
	echo "Installing ${KERNEL_UTS} to ${partition}"

	if [ -f "${location}/vmlinuz-${KERNEL_UTS}_bak" ] ; then
		sudo rm -f "${location}/vmlinuz-${KERNEL_UTS}_bak" || true
	fi

	if [ -f "${location}/vmlinuz-${KERNEL_UTS}" ] ; then
		sudo mv "${location}/vmlinuz-${KERNEL_UTS}" "${location}/vmlinuz-${KERNEL_UTS}_bak"
	fi

	sudo cp -v "${DIR}/deploy/${KERNEL_UTS}.zImage" "${location}/vmlinuz-${KERNEL_UTS}"

	if [ -f "${location}/initrd.img-${KERNEL_UTS}" ] ; then
		sudo rm -rf "${location}/initrd.img-${KERNEL_UTS}" || true
	fi

	if [ -f "${DIR}/deploy/${KERNEL_UTS}-dtbs.tar.gz" ] ; then
		if [ -d "${location}/dtbs/${KERNEL_UTS}_bak/" ] ; then
			sudo rm -rf "${location}/dtbs/${KERNEL_UTS}_bak/" || true
		fi

		if [ -d "${location}/dtbs/${KERNEL_UTS}/" ] ; then
			sudo mv "${location}/dtbs/${KERNEL_UTS}/" "${location}/dtbs/${KERNEL_UTS}_bak/" || true
		fi

		sudo mkdir -p "${location}/dtbs/${KERNEL_UTS}/"

		echo "Installing ${KERNEL_UTS}-dtbs.tar.gz to ${partition}"
		sudo tar xf "${DIR}/deploy/${KERNEL_UTS}-dtbs.tar.gz" -C "${location}/dtbs/${KERNEL_UTS}/"
		sync
	fi
}

mmc_write_boot_uname () {
	mmc_write_boot_pre

	unset older_kernel
	older_kernel=$(grep uname_r "${location}/uEnv.txt" | grep -v '#' | awk -F"=" '{print $2}' || true)

	if [ ! "x${older_kernel}" = "x" ] ; then
		if [ ! "x${older_kernel}" = "x${KERNEL_UTS}" ] ; then
			sudo sed -i -e 's:uname_r='${older_kernel}':uname_r='${KERNEL_UTS}':g' "${location}/uEnv.txt"
		fi
		echo "info: /boot/uEnv.txt: $(grep uname_r ${location}/uEnv.txt)"
	fi
}

mmc_write_boot_extlinux () {
	mmc_write_boot_pre

	unset older_kernel
	older_kernel=$(grep /boot/vmlinuz- "${location}/extlinux/extlinux.conf" | awk -F"/boot/vmlinuz-" '{print $2}' || true)

	if [ ! "x${older_kernel}" = "x" ] ; then
		if [ ! "x${older_kernel}" = "x${KERNEL_UTS}" ] ; then
			sudo sed -i -e 's:'${older_kernel}':'${KERNEL_UTS}':g' "${location}/extlinux/extlinux.conf"
		fi
		echo "info: /boot/extlinux/extlinux.conf: $(grep /boot/vmlinuz- ${location}/extlinux/extlinux.conf)"
	fi
}

mmc_write_boot () {
	if [ ! -f "${location}/zImage" ] ; then
		echo "Error: no current ${location}/zImage, this might not boot..."
	fi

	echo "Installing ${KERNEL_UTS} to ${partition}"

	if [ -f "${location}/zImage_bak" ] ; then
		sudo rm -f "${location}/zImage_bak" || true
	fi

	if [ -f "${location}/zImage" ] ; then
		sudo mv "${location}/zImage" "${location}/zImage_bak"
	fi

	#Assuming boot via zImage on first partition...
	sudo cp -v "${DIR}/deploy/${KERNEL_UTS}.zImage" "${location}/zImage"

	if [ -f "${DIR}/deploy/${KERNEL_UTS}-dtbs.tar.gz" ] ; then

		if [ -d "${location}/dtbs" ] ; then
			sudo rm -rf "${location}/dtbs" || true
		fi

		sudo mkdir -p "${location}/dtbs"

		echo "Installing ${KERNEL_UTS}-dtbs.tar.gz to ${partition}"
		sudo tar ${UNTAR} "${DIR}/deploy/${KERNEL_UTS}-dtbs.tar.gz" -C "${location}/dtbs/"
		sync
	fi
}

mmc_partition_discover () {
	boot_written="false"
	if [ -f "${DIR}/deploy/disk/uEnv.txt" ] ; then
		echo "found: /uEnv.txt"
		location="${DIR}/deploy/disk"
		mmc_write_boot
		boot_written="true"
	fi

	if [ "x${boot_written}" = "xfalse" ] ; then
		if [ -f "${DIR}/deploy/disk/boot/uEnv.txt" ] ; then
			echo "found: /boot/uEnv.txt"
			location="${DIR}/deploy/disk/boot"
			test_uname=$(grep uname_r "${DIR}/deploy/disk/boot/uEnv.txt" | awk -F"=" '{print $2}' || true)
			if [ ! "x${test_uname}" = "x" ] ; then
				echo "info: ${test_uname} was installed"
				mmc_write_boot_uname
			else
				mmc_write_boot
			fi
			boot_written="true"
		fi
	fi

	if [ "x${boot_written}" = "xfalse" ] ; then
		if [ -f "${DIR}/deploy/disk/boot/extlinux/extlinux.conf" ] ; then
			echo "found: /boot/extlinux/extlinux.conf"
			location="${DIR}/deploy/disk/boot"
			test_uname=$(grep /boot/vmlinuz- "${DIR}/deploy/disk/boot/extlinux/extlinux.conf" | awk -F"/boot/vmlinuz-" '{print $2}' || true)
			if [ ! "x${test_uname}" = "x" ] ; then
				echo "info: ${test_uname} was installed"
				mmc_write_boot_extlinux
			else
				mmc_write_boot
			fi
			boot_written="true"
		fi
	fi

	if [ "x${boot_written}" = "xfalse" ] ; then
		#Atmel: mmc 0:1: zImage /dtbs/*
		if [ -f "${DIR}/deploy/disk/BOOT.BIN" ] ; then
			echo "found: Atmel: /BOOT.BIN"
			location="${DIR}/deploy/disk"
			mmc_write_boot
			boot_written="true"
		fi
	fi

	if [ -f "${DIR}/deploy/disk/etc/fstab" ] ; then
		echo "found: /etc/fstab"
		location="${DIR}/deploy/disk"
		mmc_write_rootfs
	fi
}

mmc_unmount () {
	cd "${DIR}/deploy/disk" || exit
	sync
	sync
	cd - || exit
	sudo umount "${DIR}/deploy/disk" || true
}

mmc_detect_n_mount () {
	echo "Starting Partition Search"
	echo "-----------------------------"
	num_partitions=$(LC_ALL=C sudo fdisk -l 2>/dev/null | grep -v "DM6" | grep -v "Extended" | grep -v "swap" | grep -c "^${MMC}")

	i=0 ; while test $i -le "${num_partitions}" ; do
		partition=$(LC_ALL=C sudo fdisk -l 2>/dev/null | grep "^${MMC}" | grep -v "DM6" | grep -v "Extended" | grep -v "swap" | head -${i} | tail -1 | awk '{print $1}')
		if [ ! "x${partition}" = "x" ] ; then
			echo "Trying: [${partition}]"

			if [ ! -d "${DIR}/deploy/disk/" ] ; then
				mkdir -p "${DIR}/deploy/disk/"
			fi

			echo "Partition: [${partition}] trying: [vfat], [ext4]"
			if sudo mount -t vfat "${partition}" "${DIR}/deploy/disk/" 2>/dev/null ; then
				echo "Partition: [vfat]"
				UNTAR="xfo"
				mmc_partition_discover
				mmc_unmount
			elif sudo mount -t ext4 "${partition}" "${DIR}/deploy/disk/" 2>/dev/null ; then
				echo "Partition: [extX]"
				UNTAR="xf"
				mmc_partition_discover
				mmc_unmount
			fi
		fi
	i=$(($i+1))
	done

	echo "-----------------------------"
	echo "This script has finished..."
	echo "For verification, always test this media with your end device..."
}

unmount_partitions () {
	echo ""
	echo "Debug: Existing Partition on drive:"
	echo "-----------------------------"
	LC_ALL=C sudo fdisk -l "${MMC}"

	echo ""
	echo "Unmounting Partitions"
	echo "-----------------------------"

	NUM_MOUNTS=$(mount | grep -v none | grep "${MMC}" | wc -l)

	i=0 ; while test $i -le "${NUM_MOUNTS}" ; do
		DRIVE=$(mount | grep -v none | grep "${MMC}" | tail -1 | awk '{print $1}')
		sudo umount "${DRIVE}" >/dev/null 2>&1 || true
	i=$(($i+1))
	done

	mkdir -p "${DIR}/deploy/disk/"
	mmc_detect_n_mount
}

list_mmc () {
	echo "fdisk -l:"
	LC_ALL=C sudo fdisk -l 2>/dev/null | grep "Disk /dev/" --color=never
	echo ""
	echo "lsblk:"
	lsblk | grep -v sr0
	echo "-----------------------------"
}

check_mmc () {
	FDISK=$(LC_ALL=C sudo fdisk -l 2>/dev/null | grep "Disk ${MMC}" | awk '{print $2}')

	if [ "x${FDISK}" = "x${MMC}:" ] ; then
		echo ""
		echo "I see..."
		list_mmc
		echo -n "Are you 100% sure, on selecting [${MMC}] (y/n)? "
		read response
		if [ "x${response}" = "xy" ] ; then
			unmount_partitions
		fi
		echo ""
	else
		echo ""
		echo "Are you sure? I Don't see [${MMC}], here is what I do see..."
		echo ""
		list_mmc
		echo "Please update MMC variable in system.sh"
	fi
}

if [ -f "${DIR}/../system.sh" ] ; then
	. "${DIR}/../system.sh"

	if [ -f "${DIR}/../KERNEL/arch/arm/boot/zImage" ] ; then
		KERNEL_UTS=$(cat "${DIR}/../KERNEL/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
		if [ "x${MMC}" = "x" ] ; then
			echo "-----------------------------"
			echo "lsblk:"
			lsblk | grep -v sr0
			echo "-----------------------------"
			echo "ERROR: MMC is not defined in system.sh"
		else
			unset PARTITION_PREFIX
			echo "${MMC}" | grep mmcblk >/dev/null && PARTITION_PREFIX="p"
			check_mmc
			sync
		fi
	else
		echo "ERROR: arch/arm/boot/zImage not found, Please run build_kernel.sh before running this script..."
	fi
else
	echo "Missing system.sh, please copy system.sh.sample to system.sh and edit as needed"
	echo "cp system.sh.sample system.sh"
	echo "gedit system.sh"
fi

