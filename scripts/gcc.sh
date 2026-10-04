#!/bin/sh -e

# SPDX-FileCopyrightText: 2009 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

ARCH=$(uname -m)
DIR=$PWD

. "${DIR}/system.sh"
. "${DIR}/version.sh"

if [ -f "${DIR}/.yakbuild" ] ; then
	. "${DIR}/recipe.sh"
fi

if [ -d $HOME/dl/gcc/ ] ; then
	gcc_dir="$HOME/dl/gcc"
else
	gcc_dir="${DIR}/dl"
fi

check_glibc () {
	[ -f "./glibc_version" ] && rm "./glibc_version"
	gcc scripts/glibc_version.c -o glibc_version
	version=$(LC_ALL=C ./glibc_version | awk '{print $3}')
	echo "glibc: $version"
}

dl_generic () {
	binary="bin/${gcc_prefix}-"
	WGET="wget -c --directory-prefix=${gcc_dir}/"

	if [ "x${extracted_dir}" = "x" ] ; then
		filename_prefix=${gcc_filename_prefix}
	else
		filename_prefix=${extracted_dir}
	fi

	if [ ! -f "${gcc_dir}/${filename_prefix}/${datestamp}" ] ; then
		echo "Installing Toolchain: ${toolchain}"
		if [ ! -f "${gcc_dir}/${gcc_filename_prefix}.tar.xz" ] ; then
			echo "log: [${gcc_html_path}${gcc_filename_prefix}.tar.xz]"
			${WGET} "${gcc_html_path}${gcc_filename_prefix}.tar.xz"
		fi
		if [ -d "${gcc_dir}/${filename_prefix}" ] ; then
			rm -rf "${gcc_dir}/${filename_prefix}" || true
		fi
		tar -xf "${gcc_dir}/${gcc_filename_prefix}.tar.xz" -C "${gcc_dir}/"
		if [ -f "${gcc_dir}/${filename_prefix}/${binary}gcc" ] ; then
			touch "${gcc_dir}/${filename_prefix}/${datestamp}"
		fi
	else
		echo "Using Existing Toolchain: ${toolchain}"
	fi

	case "$ARCH" in
		armv7l|aarch64|riscv64)
			CC=""
			;;
		*)
			CC="${gcc_dir}/${filename_prefix}/${binary}"
			;;
	esac
}

dl_gcc_generic () {
	gcc_html_path="https://rcn-ee.net/mirror/crosstool/${gcc_selected}/"
	gcc_filename_prefix="x86_64-gcc-${gcc_selected}-nolibc-${gcc_prefix}"
	extracted_dir="gcc-${gcc_selected}-nolibc/${gcc_prefix}"
	dl_generic
}

gcc_toolchain () {
	unset extracted_dir

	#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/
	case "${toolchain_version}" in
		8)  gcc_selected="8.5.0"  ; gcc_date="2018" ;;
		9)  gcc_selected="9.5.0"  ; gcc_date="2019" ;;
		10) gcc_selected="10.5.0" ; gcc_date="2020" ;;
		11) gcc_selected="11.5.0" ; gcc_date="2021" ;;
		12) gcc_selected="12.5.0" ; gcc_date="2022" ;;
		13) gcc_selected="13.5.0" ; gcc_date="2023" ;;
		14) gcc_selected="14.4.0" ; gcc_date="2024" ;;
		15) gcc_selected="15.3.0" ; gcc_date="2025" ;;
		16) gcc_selected="16.2.0" ; gcc_date="2026" ;;
		*)  echo "Error: Invalid toolchain_version in version.sh"; exit 1 ;;
	esac

	case "${KERNEL_ARCH}" in
		arm)
			gcc_prefix="arm-linux-gnueabi"
			datestamp="${gcc_date}.${gcc_selected}-${gcc_prefix}"
			dl_gcc_generic
			;;
		arm64)
			gcc_prefix="aarch64-linux"
			datestamp="${gcc_date}.${gcc_selected}-${gcc_prefix}-gcc"
			dl_gcc_generic
			;;
		riscv)
			gcc_prefix="riscv64-linux"
			datestamp="${gcc_date}.${gcc_selected}-${gcc_prefix}-gcc"
			dl_gcc_generic
			;;
		*)
			echo "Error: Unsupported KERNEL_ARCH: ${KERNEL_ARCH}"
			exit 1
			;;
	esac
}

if [ "x${CC}" = "x" ] && [ "x${ARCH}" != "xarmv7l" ] && [ "x${ARCH}" != "xaarch64" ] ; then
	check_glibc
	gcc_toolchain
fi

# Map Kernel Arch to validation string
check=""
case "${KERNEL_ARCH}" in
	arm)    check="arm" ;;
	arm64)  check="aarch64" ;;
	riscv)  check="riscv" ;;
esac

if [ -z "${check}" ] ; then
	echo "ERROR: fix: scripts/gcc.sh..."
	exit 2
else
	# Validate compiler targets
	GCC_TEST=$(LC_ALL=C "${CC}"gcc -v 2>&1 | grep "Target:" | grep "${check}" || true)
fi

if [ -z "${GCC_TEST}" ] ; then
	echo "-----------------------------"
	echo "scripts/gcc: Error: The GCC Cross Compiler you setup in system.sh (CC variable) is invalid."
	echo "-----------------------------"
	gcc_toolchain
fi

echo "-----------------------------"
echo "scripts/gcc: Using: $(LC_ALL=C "${CC}"gcc --version)"
echo "-----------------------------"
echo "CC=${CC}" > "${DIR}/.CC"
