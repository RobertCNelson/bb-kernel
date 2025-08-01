#!/bin/sh -e

DIR=$PWD

. "${DIR}/version.sh"
unset CC
. "${DIR}/.CC"

if [ -f ${DIR}/KERNEL/Makefile ] ; then
	cd ${DIR}/KERNEL/

	cp -v "${DIR}/patches/debian.config" .config
	cp -v "${DIR}/patches/beagle.config" beagle.config
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	ARCH=${KERNEL_ARCH} ./scripts/kconfig/merge_config.sh -m -r .config beagle.config
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	cp -v .config "${DIR}/patches/defconfig"

	cd ${DIR}/
fi
