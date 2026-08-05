#!/bin/bash

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

#
#https://packages.debian.org/source/sid/linux
#
trixie_kernel_branch="6.12"
trixie_kernel_tag="6.12.100-1"
#
forky_kernel_branch="7.1"
forky_kernel_tag="7.1.3-1"
#
sid_kernel_branch="7.1"
sid_kernel_tag="7.1.5-1"
#
exp_kernel_branch="7.2"
#exp_kernel_tag="7.2.1-1~exp1"
exp_kernel_tag="7.2~rc5-1~exp1"
#

mirror_site="http://192.168.1.10/debian/pool/main/l/linux"
debian_site="http://deb.debian.org/debian/pool/main/l/linux"
debian_security_site="http://deb.debian.org/debian-security/pool/main/l/linux"
incoming_site="http://incoming.debian.org/debian-buildd/pool/main/l/linux"

dl_deb () {
	if [ ! -f ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${mirror_site}/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${debian_site}/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${incoming_site}/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${debian_security_site}/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb
	fi

	if [ -f ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ] ; then
		dpkg -x ./dl/linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb ./dl/tmp/
		if [ -f ./dl/tmp/usr/src/linux-config-${kernel_branch}/config.${dpkg_arch}_${config}.xz ] ; then
			echo "[linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb]"
			xzcat -v ./dl/tmp/usr/src/linux-config-${kernel_branch}/config.${dpkg_arch}_${config}.xz > ./patches/debian.config
		else
			tree ./dl/tmp/usr/src/linux-config-${kernel_branch}/
			exit 2
		fi
		rm -rf ./dl/tmp/ || true
	else
		echo "[linux-config-${kernel_branch}_${kernel_tag}_${dpkg_arch}.deb] NOT BUILT YET"
	fi
}

dl_distro () {
	dpkg_arch="armhf"
	config="none_armmp"
	dl_deb
}

kernel_branch="${trixie_kernel_branch}"
kernel_tag="${trixie_kernel_tag}"
dl_distro

rm -rf ./dl/ || true

#
