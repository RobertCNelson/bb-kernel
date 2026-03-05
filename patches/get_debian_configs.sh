#!/bin/bash

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

#
#https://packages.debian.org/source/bookworm/linux
#
abi="6.1.0-43"
kernel="6.1.162-1"
#

mirror_site="http://192.168.1.10/debian/pool/main/l/linux"
debian_site="http://deb.debian.org/debian/pool/main/l/linux"
debian_security_site="http://deb.debian.org/debian-security/pool/main/l/linux"
incoming_site="http://incoming.debian.org/debian-buildd/pool/main/l/linux"

dl_deb () {
	if [ ! -f ./dl/linux-config-${abi}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${mirror_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${debian_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${incoming_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -cq --directory-prefix=./dl/ ${debian_security_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		dpkg -x ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ./dl/tmp/
		cp -v ./dl/tmp/boot/config-${abi}-${image} ./debian.config
		rm -rf ./dl/tmp/ || true
	fi
}

dpkg_arch="armhf"
image="rt-armmp"
unsigned=""
dl_deb

rm -rf ./dl/ || true

#
