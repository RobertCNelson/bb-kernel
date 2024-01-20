#!/bin/bash

#
#https://packages.debian.org/source/bookworm/linux
#
abi="6.1.0-17"
kernel="6.1.69-1"
#

mirror_site="http://192.168.1.12/debian/pool/main/l/linux"
debian_site="http://ftp.us.debian.org/debian/pool/main/l/linux"
incoming_site="http://incoming.debian.org/debian-buildd/pool/main/l/linux"

dl_deb () {
	wget -c --directory-prefix=./dl/ ${mirror_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -c --directory-prefix=./dl/ ${debian_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -c --directory-prefix=./dl/ ${incoming_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		dpkg -x ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ./dl/tmp/
		cp -v ./dl/tmp/boot/config-${abi}-${image} ./debian
		rm -rf ./dl/tmp/ || true
	fi
}

dpkg_arch="armhf"
image="armmp"
unsigned=""
dl_deb

rm -rf ./dl/ || true

#
