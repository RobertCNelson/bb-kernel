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

dl_gcc_generic () {
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

	if [ "x${ARCH}" = "xarmv7l" ] ; then
		#using native gcc
		CC=
	else
		CC="${gcc_dir}/${filename_prefix}/${binary}"
	fi
}

gcc_toolchain () {
	unset extracted_dir
	case "${toolchain}" in
	gcc_linaro_gnueabihf_6|gcc_6_arm)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/6.5.0/x86_64-gcc-6.5.0-nolibc-arm-linux-gnueabi.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/6.5.0/"
		gcc_filename_prefix="x86_64-gcc-6.5.0-nolibc-arm-linux-gnueabi"
		extracted_dir="gcc-6.5.0-nolibc/arm-linux-gnueabi"
		gcc_banner="arm-linux-gcc (GCC) 6.5.0"
		gcc_copyright="2017"
		datestamp="2017.6.5.0-arm-linux-gnueabi"

		binary="bin/arm-linux-gnueabi-"
		;;
	gcc_linaro_gnueabihf_7|gcc_arm_eabi_7|gcc_7_arm)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/x86_64-gcc-7.5.0-nolibc-arm-linux-gnueabi.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/"
		gcc_filename_prefix="x86_64-gcc-7.5.0-nolibc-arm-linux-gnueabi"
		extracted_dir="gcc-7.5.0-nolibc/arm-linux-gnueabi"
		gcc_banner="arm-linux-gcc (GCC) 7.5.0"
		gcc_copyright="2017"
		datestamp="2017.7.5.0-arm-linux-gnueabi"

		binary="bin/arm-linux-gnueabi-"
		;;
	gcc_arm_gnueabihf_8|gcc_arm_eabi_8|gcc_8_arm)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/x86_64-gcc-8.4.0-nolibc-arm-linux-gnueabi.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/"
		gcc_filename_prefix="x86_64-gcc-8.4.0-nolibc-arm-linux-gnueabi"
		extracted_dir="gcc-8.4.0-nolibc/arm-linux-gnueabi"
		gcc_banner="arm-linux-gcc (GCC) 8.4.0"
		gcc_copyright="2018"
		datestamp="2018.8.4.0-arm-linux-gnueabi"

		binary="bin/arm-linux-gnueabi-"
		;;
	gcc_arm_gnueabihf_9|gcc_arm_eabi_9|gcc_9_arm)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/x86_64-gcc-9.3.0-nolibc-arm-linux-gnueabi.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/"
		gcc_filename_prefix="x86_64-gcc-9.3.0-nolibc-arm-linux-gnueabi"
		extracted_dir="gcc-9.3.0-nolibc/arm-linux-gnueabi"
		gcc_banner="arm-linux-gcc (GCC) 9.3.0"
		gcc_copyright="2019"
		datestamp="2019.9.3.0-arm-linux-gnueabi"

		binary="bin/arm-linux-gnueabi-"
		;;
	gcc_arm_gnueabihf_10|gcc_arm_eabi_10|gcc_10_arm)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/x86_64-gcc-10.3.0-nolibc-arm-linux-gnueabi.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/"
		gcc_filename_prefix="x86_64-gcc-10.3.0-nolibc-arm-linux-gnueabi"
		extracted_dir="gcc-10.3.0-nolibc/arm-linux-gnueabi"
		gcc_banner="arm-linux-gcc (GCC) 10.3.0"
		gcc_copyright="2020"
		datestamp="2020.10.3.0-arm-linux-gnueabi"

		binary="bin/arm-linux-gnueabi-"
		;;
	gcc_linaro_aarch64_gnu_6|gcc_6_aarch64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/6.5.0/x86_64-gcc-6.5.0-nolibc-aarch64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/6.5.0/"
		gcc_filename_prefix="x86_64-gcc-6.5.0-nolibc-aarch64-linux"
		extracted_dir="gcc-6.5.0-nolibc/aarch64-linux"
		gcc_banner="aarch64-linux-gcc (GCC) 6.5.0"
		gcc_copyright="2017"
		datestamp="2017.6.5.0-aarch64-linux-gcc"

		binary="bin/aarch64-linux-"
		;;
	gcc_linaro_aarch64_gnu_7|gcc_7_aarch64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/x86_64-gcc-7.5.0-nolibc-aarch64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/"
		gcc_filename_prefix="x86_64-gcc-7.5.0-nolibc-aarch64-linux"
		extracted_dir="gcc-7.5.0-nolibc/aarch64-linux"
		gcc_banner="aarch64-linux-gcc (GCC) 7.5.0"
		gcc_copyright="2017"
		datestamp="2017.7.5.0-aarch64-linux-gcc"

		binary="bin/aarch64-linux-"
		;;
	gcc_arm_aarch64_gnu_8|gcc_8_aarch64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/x86_64-gcc-8.4.0-nolibc-aarch64-linux.tar.gz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/"
		gcc_filename_prefix="x86_64-gcc-8.4.0-nolibc-aarch64-linux"
		extracted_dir="gcc-8.4.0-nolibc/aarch64-linux"
		gcc_banner="aarch64-linux-gcc (GCC) 8.4.0"
		gcc_copyright="2018"
		datestamp="2018.8.4.0-aarch64-linux-gcc"

		binary="bin/aarch64-linux-"
		;;
	gcc_arm_aarch64_gnu_9|gcc_9_aarch64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/x86_64-gcc-9.3.0-nolibc-aarch64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/"
		gcc_filename_prefix="x86_64-gcc-9.3.0-nolibc-aarch64-linux"
		extracted_dir="gcc-9.3.0-nolibc/aarch64-linux"
		gcc_banner="aarch64-linux-gcc (GCC) 9.3.0"
		gcc_copyright="2019"
		datestamp="2019.9.3.0-aarch64-linux-gcc"

		binary="bin/aarch64-linux-"
		;;
	gcc_arm_aarch64_gnu_10|gcc_10_aarch64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/x86_64-gcc-10.3.0-nolibc-aarch64-linux.tar.gz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/"
		gcc_filename_prefix="x86_64-gcc-10.3.0-nolibc-aarch64-linux"
		extracted_dir="gcc-10.3.0-nolibc/aarch64-linux"
		gcc_banner="aarch64-linux-gcc (GCC) 10.3.0"
		gcc_copyright="2020"
		datestamp="2020.10.3.0-aarch64-linux-gcc"

		binary="bin/aarch64-linux-"
		;;
	gcc_7_riscv64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/x86_64-gcc-7.5.0-nolibc-riscv64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/7.5.0/"
		gcc_filename_prefix="x86_64-gcc-7.5.0-nolibc-riscv64-linux"
		extracted_dir="gcc-7.5.0-nolibc/riscv64-linux"
		gcc_banner="riscv64-linux-gcc (GCC) 7.5.0"
		gcc_copyright="2017"
		datestamp="2017.7.5.0-riscv64-linux-gcc"

		binary="bin/riscv64-linux-"
		;;
	gcc_8_riscv64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/x86_64-gcc-8.4.0-nolibc-riscv64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.4.0/"
		gcc_filename_prefix="x86_64-gcc-8.4.0-nolibc-riscv64-linux"
		extracted_dir="gcc-8.4.0-nolibc/riscv64-linux"
		gcc_banner="riscv64-linux-gcc (GCC) 8.4.0"
		gcc_copyright="2018"
		datestamp="2018.8.4.0-riscv64-linux-gcc"

		binary="bin/riscv64-linux-"
		;;
	gcc_9_riscv64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/x86_64-gcc-9.3.0-nolibc-riscv64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/9.3.0/"
		gcc_filename_prefix="x86_64-gcc-9.3.0-nolibc-riscv64-linux"
		extracted_dir="gcc-9.3.0-nolibc/riscv64-linux"
		gcc_banner="riscv64-linux-gcc (GCC) 9.3.0"
		gcc_copyright="2019"
		datestamp="2019.9.3.0-riscv64-linux-gcc"

		binary="bin/riscv64-linux-"
		;;
	gcc_10_riscv64)
		#
		#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/x86_64-gcc-10.3.0-nolibc-riscv64-linux.tar.xz
		#

		gcc_html_path="https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/"
		gcc_filename_prefix="x86_64-gcc-10.3.0-nolibc-riscv64-linux"
		extracted_dir="gcc-10.3.0-nolibc/riscv64-linux"
		gcc_banner="riscv64-linux-gcc (GCC) 10.3.0"
		gcc_copyright="2020"
		datestamp="2020.10.3.0-riscv64-linux-gcc"

		binary="bin/riscv64-linux-"
		;;
	*)
		echo "bug: maintainer forgot to set:"
		echo "toolchain=\"xzy\" in version.sh"
		exit 1
		;;
	esac

	dl_gcc_generic
}

if [ "x${CC}" = "x" ] && [ "x${ARCH}" != "xarmv7l" ] ; then
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
