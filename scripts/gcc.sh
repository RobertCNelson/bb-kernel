#!/bin/sh -e
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

ARCH=$(uname -m)
DIR=$PWD

. "${DIR}/system.sh"

#For:
#toolchain
. "${DIR}/version.sh"

if [  -f "${DIR}/.yakbuild" ] ; then
	. "${DIR}/recipe.sh"
fi

if [ -d $HOME/dl/gcc/ ] ; then
	gcc_dir="$HOME/dl/gcc"
else
	gcc_dir="${DIR}/dl"
fi

check_glibc () {
	if [ -f ./glibc_version ] ; then
		rm ./glibc_version || true
	fi

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
		echo "-----------------------------"
		${WGET} "${gcc_html_path}${gcc_filename_prefix}.tar.xz"
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

	if [ "x${ARCH}" = "xarmv7l" ] || [ "x${ARCH}" = "xaarch64" ] ; then
		#using native gcc
		CC=
	else
		CC="${gcc_dir}/${filename_prefix}/${binary}"
	fi
}

dl_gcc_generic_old () {
	gcc_html_path="https://releases.linaro.org/${gcc_selected}/"

	dl_generic
}

dl_gcc_generic () {
	gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/${gcc_selected}/"
	gcc_filename_prefix="x86_64-gcc-${gcc_selected}-nolibc-${gcc_prefix}"
	extracted_dir="gcc-${gcc_selected}-nolibc/${gcc_prefix}"

	dl_generic
}

gcc_toolchain () {
	unset extracted_dir

	#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/
	gcc6="6.5.0"
	gcc7="7.5.0"
	gcc8="8.5.0"
	gcc9="9.5.0"
	gcc10="10.5.0"
	gcc11="11.4.0"
	gcc12="12.3.0"
	gcc13="13.2.0"

	case "${toolchain}" in
	gcc_linaro_gnueabihf_4_9)
		#
		#https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz
		#

		gcc_prefix="arm-linux-gnueabihf"
		datestamp="2015.4.9.4-${gcc_prefix}"

		gcc_selected="components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf"
		gcc_filename_prefix="gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf"

		dl_gcc_generic_old
		;;
	gcc_linaro_gnueabihf_5)
		#
		#https://releases.linaro.org/components/toolchain/binaries/5.4-2017.05/arm-linux-gnueabihf/gcc-linaro-5.4.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz
		#https://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz
		#

		gcc_prefix="arm-linux-gnueabihf"
		datestamp="2015.5.5.0-${gcc_prefix}"

		gcc_selected="components/toolchain/binaries/5.5-2017.10/arm-linux-gnueabihf"
		gcc_filename_prefix="gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf"

		dl_gcc_generic_old
		;;
	gcc_linaro_gnueabihf_6|gcc_6_arm)
		gcc_selected=${gcc6}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2017.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_linaro_gnueabihf_7|gcc_arm_eabi_7|gcc_7_arm)
		gcc_selected=${gcc7}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2017.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_arm_gnueabihf_8|gcc_arm_eabi_8|gcc_8_arm)
		gcc_selected=${gcc8}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2018.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_arm_gnueabihf_9|gcc_arm_eabi_9|gcc_9_arm)
		gcc_selected=${gcc9}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2019.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_arm_gnueabihf_10|gcc_arm_eabi_10|gcc_10_arm)
		gcc_selected=${gcc10}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2020.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_11_arm)
		gcc_selected=${gcc11}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2021.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_12_arm)
		gcc_selected=${gcc12}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2022.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_13_arm)
		gcc_selected=${gcc13}
		gcc_prefix="arm-linux-gnueabi"
		datestamp="2023.${gcc_selected}-${gcc_prefix}"
		dl_gcc_generic
		;;
	gcc_linaro_aarch64_gnu_6|gcc_6_aarch64)
		gcc_selected=${gcc6}
		gcc_prefix="aarch64-linux"
		datestamp="2017.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_linaro_aarch64_gnu_7|gcc_7_aarch64)
		gcc_selected=${gcc7}
		gcc_prefix="aarch64-linux"
		datestamp="2017.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_arm_aarch64_gnu_8|gcc_8_aarch64)
		gcc_selected=${gcc8}
		gcc_prefix="aarch64-linux"
		datestamp="2018.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_arm_aarch64_gnu_9|gcc_9_aarch64)
		gcc_selected=${gcc9}
		gcc_prefix="aarch64-linux"
		datestamp="2019.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_arm_aarch64_gnu_10|gcc_10_aarch64)
		gcc_selected=${gcc10}
		gcc_prefix="aarch64-linux"
		datestamp="2020.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_11_aarch64)
		gcc_selected=${gcc11}
		gcc_prefix="aarch64-linux"
		datestamp="2021.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_12_aarch64)
		gcc_selected=${gcc12}
		gcc_prefix="aarch64-linux"
		datestamp="2022.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_13_aarch64)
		gcc_selected=${gcc13}
		gcc_prefix="aarch64-linux"
		datestamp="2023.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_7_riscv64)
		gcc_selected=${gcc7}
		gcc_prefix="riscv64-linux"
		datestamp="2017.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_8_riscv64)
		gcc_selected=${gcc8}
		gcc_prefix="riscv64-linux"
		datestamp="2018.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_9_riscv64)
		gcc_selected=${gcc9}
		gcc_prefix="riscv64-linux"
		datestamp="2019.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_10_riscv64)
		gcc_selected=${gcc10}
		gcc_prefix="riscv64-linux"
		datestamp="2020.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_11_riscv64)
		gcc_selected=${gcc11}
		gcc_prefix="riscv64-linux"
		datestamp="2021.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_12_riscv64)
		gcc_selected=${gcc12}
		gcc_prefix="riscv64-linux"
		datestamp="2022.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	gcc_13_riscv64)
		gcc_selected=${gcc13}
		gcc_prefix="riscv64-linux"
		datestamp="2023.${gcc_selected}-${gcc_prefix}-gcc"
		dl_gcc_generic
		;;
	*)
		echo "bug: maintainer forgot to set:"
		echo "toolchain=\"xzy\" in version.sh"
		exit 1
		;;
	esac
}

if [ "x${CC}" = "x" ] && [ "x${ARCH}" != "xarmv7l" ] && [ "x${ARCH}" != "xaarch64" ] ; then
	check_glibc
	gcc_toolchain
fi

unset check
if [ "x${KERNEL_ARCH}" = "xarm" ] ; then
	check="arm"
fi
if [ "x${KERNEL_ARCH}" = "xarm64" ] ; then
	check="aarch64"
fi
if [ "x${KERNEL_ARCH}" = "xriscv" ] ; then
	check="riscv"
fi

if [ "x${check}" = "x" ] ; then
	echo "ERROR: fix: scripts/gcc.sh..."
	exit 2
else
	GCC_TEST=$(LC_ALL=C "${CC}gcc" -v 2>&1 | grep "Target:" | grep ${check} || true)
fi

if [ "x${GCC_TEST}" = "x" ] ; then
	echo "-----------------------------"
	echo "scripts/gcc: Error: The GCC Cross Compiler you setup in system.sh (CC variable) is invalid."
	echo "-----------------------------"
	gcc_toolchain
fi

echo "-----------------------------"
echo "scripts/gcc: Using: $(LC_ALL=C "${CC}"gcc --version)"
echo "-----------------------------"
echo "CC=${CC}" > "${DIR}/.CC"
