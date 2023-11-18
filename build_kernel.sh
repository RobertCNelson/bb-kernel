#!/bin/sh -e
#
# Copyright (c) 2009-2021 Robert Nelson <robertcnelson@gmail.com>
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

DIR=$PWD
git_bin=$(which git)

mkdir -p "${DIR}/deploy/"

patch_kernel () {
	cd "${DIR}/KERNEL" || exit

	export DIR
	/bin/bash -e "${DIR}/patch.sh" || { ${git_bin} add . ; exit 1 ; }

	if [ ! -f "${DIR}/.yakbuild" ] ; then
		if [ ! "${RUN_BISECT}" ] ; then
			${git_bin} add --all
			${git_bin} commit --allow-empty -a -m "${KERNEL_TAG}${BUILD} patchset"
		fi
	fi

	cd "${DIR}/" || exit
}

copy_defconfig () {
	cd "${DIR}/KERNEL" || exit
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" distclean
	if [ ! -f "${DIR}/.yakbuild" ] ; then
		make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" "${config}"
		cp -v .config "${DIR}/patches/ref_${config}"
		cp -v "${DIR}/patches/defconfig" .config
	else
		make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" rcn-ee_defconfig
	fi
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" olddefconfig
	cd "${DIR}/" || exit
}

make_menuconfig () {
	cd "${DIR}/KERNEL" || exit
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" oldconfig
	make ARCH=${KERNEL_ARCH} CROSS_COMPILE="${CC}" menuconfig
	if [ ! -f "${DIR}/.yakbuild" ] ; then
		cp -v .config "${DIR}/patches/defconfig"
	fi
	cd "${DIR}/" || exit
}

make_kernel () {
	if [ "x${KERNEL_ARCH}" = "xarm" ] ; then
		image="zImage"
	else
		image="Image"
	fi

	unset address

	##uImage, if you really really want a uImage, zreladdr needs to be defined on the build line going forward...
	##make sure to install your distro's version of mkimage
	#image="uImage"
	#address="LOADADDR=${ZRELADDR}"

	cd "${DIR}/KERNEL" || exit
	echo "-----------------------------"
	echo "make -j${CORES} ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE=\"${CC}\" ${address} ${image} modules"
	echo "-----------------------------"
	make -j${CORES} ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE="${CC}" ${address} ${image} modules
	echo "-----------------------------"
	echo "make -j${CORES} ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE=\"${CC}\" dtbs"
	echo "-----------------------------"
	make -j${CORES} ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE="${CC}" dtbs
	echo "-----------------------------"

	KERNEL_UTS=$(cat "${DIR}/KERNEL/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

	if [ -f "${DIR}/deploy/${KERNEL_UTS}.${image}" ] ; then
		rm -rf "${DIR}/deploy/${KERNEL_UTS}.${image}" || true
		rm -rf "${DIR}/deploy/config-${KERNEL_UTS}" || true
	fi

	if [ -f ./arch/${KERNEL_ARCH}/boot/${image} ] ; then
		cp -v arch/${KERNEL_ARCH}/boot/${image} "${DIR}/deploy/${KERNEL_UTS}.${image}"
		cp -v .config "${DIR}/deploy/config-${KERNEL_UTS}"
	fi

	cd "${DIR}/" || exit

	if [ ! -f "${DIR}/deploy/${KERNEL_UTS}.${image}" ] ; then
		export ERROR_MSG="File Generation Failure: [${KERNEL_UTS}.${image}]"
		/bin/sh -e "${DIR}/scripts/error.sh" && { exit 1 ; }
	else
		ls -lh "${DIR}/deploy/${KERNEL_UTS}.${image}"
	fi
}

make_pkg () {
	cd "${DIR}/KERNEL" || exit

	deployfile="-${pkg}.tar.gz"
	tar_options="--create --gzip --file"

	if [ -f "${DIR}/deploy/${KERNEL_UTS}${deployfile}" ] ; then
		rm -rf "${DIR}/deploy/${KERNEL_UTS}${deployfile}" || true
	fi

	if [ -d "${DIR}/deploy/tmp" ] ; then
		rm -rf "${DIR}/deploy/tmp" || true
	fi
	mkdir -p "${DIR}/deploy/tmp"

	echo "-----------------------------"
	echo "Building ${pkg} archive..."

	case "${pkg}" in
	modules)
		make -s ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE="${CC}" modules_install INSTALL_MOD_PATH="${DIR}/deploy/tmp"
		;;
	dtbs)
		make -s ARCH=${KERNEL_ARCH} LOCALVERSION=${BUILD} CROSS_COMPILE="${CC}" dtbs_install INSTALL_DTBS_PATH="${DIR}/deploy/tmp"
		;;
	esac

	echo "Compressing ${KERNEL_UTS}${deployfile}..."
	cd "${DIR}/deploy/tmp" || true
	tar ${tar_options} "../${KERNEL_UTS}${deployfile}" ./*

	cd "${DIR}/" || exit
	rm -rf "${DIR}/deploy/tmp" || true

	if [ ! -f "${DIR}/deploy/${KERNEL_UTS}${deployfile}" ] ; then
		export ERROR_MSG="File Generation Failure: [${KERNEL_UTS}${deployfile}]"
		/bin/sh -e "${DIR}/scripts/error.sh" && { exit 1 ; }
	else
		ls -lh "${DIR}/deploy/${KERNEL_UTS}${deployfile}"
	fi
}

make_modules_pkg () {
	pkg="modules"
	make_pkg
}

make_dtbs_pkg () {
	pkg="dtbs"
	make_pkg
}

if [  -f "${DIR}/.yakbuild" ] ; then
	if [ -f "${DIR}/recipe.sh.sample" ] ; then
		if [ ! -f "${DIR}/recipe.sh" ] ; then
			cp -v "${DIR}/recipe.sh.sample" "${DIR}/recipe.sh"
		fi
	fi
fi

/bin/sh -e "${DIR}/tools/host_det.sh" || { exit 1 ; }

if [ ! -f "${DIR}/system.sh" ] ; then
	cp -v "${DIR}/system.sh.sample" "${DIR}/system.sh"
fi

unset CC
unset LINUX_GIT
. "${DIR}/system.sh"
if [  -f "${DIR}/.yakbuild" ] ; then
	. "${DIR}/recipe.sh"
fi
/bin/sh -e "${DIR}/scripts/gcc.sh" || { exit 1 ; }
. "${DIR}/.CC"
echo "CROSS_COMPILE=${CC}"
if [ -f /usr/bin/ccache ] ; then
	echo "ccache [enabled]"
	CC="ccache ${CC}"
fi

. "${DIR}/version.sh"
export LINUX_GIT

if [ ! "${CORES}" ] ; then
	CORES=$(getconf _NPROCESSORS_ONLN)
fi

#unset FULL_REBUILD
FULL_REBUILD=1
if [ "${FULL_REBUILD}" ] ; then
	/bin/sh -e "${DIR}/scripts/git.sh" || { exit 1 ; }

	if [ "${RUN_BISECT}" ] ; then
		/bin/sh -e "${DIR}/scripts/bisect.sh" || { exit 1 ; }
	fi

	patch_kernel
	copy_defconfig
fi
if [ ! "${AUTO_BUILD}" ] ; then
	make_menuconfig
fi
if [  -f "${DIR}/.yakbuild" ] ; then
	BUILD=$(echo ${kernel_tag} | sed 's/[^-]*//'|| true)
fi
make_kernel
if [ ! "${AUTO_BUILD_DONT_PKG}" ] ; then
	make_modules_pkg
	make_dtbs_pkg
fi
echo "-----------------------------"
echo "Script Complete"
echo "${KERNEL_UTS}" > kernel_version
echo "eewiki.net: [user@localhost:~$ export kernel_version=${KERNEL_UTS}]"
echo "-----------------------------"
