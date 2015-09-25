#!/bin/sh
#
ARCH=$(uname -m)

config="omap2plus_defconfig"

#toolchain="gcc_linaro_eabi_4_8"
#toolchain="gcc_linaro_eabi_4_9"
#toolchain="gcc_linaro_gnueabi_4_6"
toolchain="gcc_linaro_gnueabihf_4_7"
#toolchain="gcc_linaro_gnueabihf_4_8"
#toolchain="gcc_linaro_gnueabihf_4_9"

#Kernel/Build
KERNEL_REL=3.8
KERNEL_TAG=${KERNEL_REL}.13
BUILD=xenomai-r78

#v4.X-rcX + upto SHA
#prev_KERNEL_SHA=""
#KERNEL_SHA=""

#git branch
BRANCH="3.8.13-xenomai"

DISTRO=cross
DEBARCH=armhf
#
