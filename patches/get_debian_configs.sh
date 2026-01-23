#!/bin/bash

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

#
#https://packages.debian.org/source/trixie/linux
#
abi="6.12"
kernel="6.12.63-1"
#

mirror_site="http://192.168.1.10/debian/pool/main/l/linux"
debian_site="http://deb.debian.org/debian/pool/main/l/linux"
debian_security_site="http://deb.debian.org/debian-security/pool/main/l/linux"
incoming_site="http://incoming.debian.org/debian-buildd/pool/main/l/linux"

dl_deb () {
	if [ ! -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cnv --directory-prefix=./dl/ ${mirror_site}/linux-config-${abi}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cnv --directory-prefix=./dl/ ${debian_site}/linux-config-${abi}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cnv --directory-prefix=./dl/ ${incoming_site}/linux-config-${abi}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cnv --directory-prefix=./dl/ ${debian_security_site}/linux-config-${abi}_${kernel}_${dpkg_arch}.deb
	fi

	if [ -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		dpkg -x ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ./dl/tmp/
		if [ -f ./dl/tmp/usr/src/linux-config-${abi}/config.${dpkg_arch}_${config}.xz ] ; then
			xzcat ./dl/tmp/usr/src/linux-config-${abi}/config.${dpkg_arch}_${config}.xz > ./debian.config
		else
			tree ./dl/tmp/usr/src/linux-config-${abi}/
			exit 2
		fi
		rm -rf ./dl/tmp/ || true
	fi
}

dpkg_arch="armhf"
config="rt_armmp"
dl_deb

rm -rf ./dl/ || true

#
