#!/bin/bash

#
#https://packages.debian.org/source/bullseye/linux
#
abi="5.10.0-28"
kernel="5.10.209-2"
#

mirror_site="http://192.168.1.10/debian/pool/main/l/linux"
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
image="rt-armmp"
unsigned=""
dl_deb

rm -rf ./dl/ || true

#
