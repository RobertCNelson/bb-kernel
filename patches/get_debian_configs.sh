#!/bin/bash

abi="5.13.0-trunk"
kernel="5.13.12-1~exp1"

debian_site="http://ftp.de.debian.org/debian/pool/main/l/linux"
incoming_site="http://incoming.debian.org/debian-buildd/pool/main/l/linux"

dl_deb () {
	wget -c --directory-prefix=./dl/ ${debian_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb

	if [ ! -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		wget -c --directory-prefix=./dl/ ${incoming_site}/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb
	fi

	if [ -f ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ] ; then
		dpkg -x ./dl/linux-image-${abi}-${image}${unsigned}_${kernel}_${dpkg_arch}.deb ./dl/tmp/
		cp -v ./dl/tmp/boot/config-${abi}-${image} ./debian-${image}
		rm -rf ./dl/tmp/ || true
	fi
}

dpkg_arch="armhf"
image="armmp"
unsigned=""
dl_deb

dpkg_arch="armhf"
image="armmp-lpae"
unsigned=""
dl_deb

rm -rf ./dl/ || true

#
