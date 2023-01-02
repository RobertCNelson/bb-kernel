#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

build_prefix="-bone"
branch_prefix="am33x-v"
branch_postfix=""

#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_linaro_gnueabi_4_6"
#toolchain="gcc_linaro_gnueabihf_4_7"
toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"
#toolchain="gcc_linaro_gnueabihf_5"

#Kernel
KERNEL_REL=3.12
KERNEL_TAG=${KERNEL_REL}.13
#Kernel Build
BUILD=${build_prefix}12

#v6.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="${branch_prefix}${KERNEL_REL}${branch_postfix}"

DISTRO=xross
#
