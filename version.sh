#!/bin/sh

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
# SPDX-License-Identifier: MIT

#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-bone"
branch_prefix="am33x-v"
branch_postfix=""

#Changes
#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v7.2-rc1
#
#Cross Compilers
#https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/

# Options: arm, arm64, riscv
KERNEL_ARCH=arm

# Options: 8, 9, 10, 11, 12, 13, 14, 15, 16
toolchain_version="16"

#Wireless:
#https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git
WIRELESS_REGDB="2026-09-03"

#Kernel
linux_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
linux_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux.git"
#
KERNEL_REL=7.2
KERNEL_TAG=${KERNEL_REL}.9
#https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/x.y/
kernel_rt=".X-rtY"
#Kernel Build
BUILD=${build_prefix}17.1

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross
#
