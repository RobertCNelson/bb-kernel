#!/bin/sh -e

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD

. "${DIR}/version.sh"
unset CC
. "${DIR}/.CC"

if [ -f ${DIR}/KERNEL/Makefile ] ; then
	cd ${DIR}/KERNEL/

	cp -v "${DIR}/patches/debian.config" .config
	cp -v "${DIR}/patches/beagle.config" beagle.config
	cp -v "${DIR}/patches/configs_removed_on_mainline.config" configs_removed_on_mainline.config
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	ARCH=${KERNEL_ARCH} ./scripts/kconfig/merge_config.sh -m -r .config beagle.config configs_removed_on_mainline.config
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	cp -v .config "${DIR}/patches/defconfig"
	rm beagle.config || true
	rm configs_removed_on_mainline.config || true

	cd ${DIR}/
fi
