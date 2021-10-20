#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-bone"
branch_prefix="am33x-v"
branch_postfix=""

#https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/process/changes.rst?h=v5.10-rc1
#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"
#arm64
#KERNEL_ARCH=arm64
#DEBARCH=arm64
#toolchain="gcc_6_aarch64"
#toolchain="gcc_7_aarch64"
#toolchain="gcc_8_aarch64"
#toolchain="gcc_9_aarch64"
#toolchain="gcc_10_aarch64"
#toolchain="gcc_11_aarch64"
#riscv64
#KERNEL_ARCH=riscv
#DEBARCH=riscv64
#toolchain="gcc_7_riscv64"
#toolchain="gcc_8_riscv64"
#toolchain="gcc_9_riscv64"
#toolchain="gcc_10_riscv64"
#toolchain="gcc_11_riscv64"

#Kernel
KERNEL_REL=5.10
KERNEL_TAG=${KERNEL_REL}.73
kernel_rt=".73-rt54"
#Kernel Build
BUILD=${build_prefix}55

#v5.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross
#
