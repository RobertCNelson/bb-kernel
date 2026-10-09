#!/bin/bash

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
# SPDX-License-Identifier: MIT

#https://packages.debian.org/source/sid/linux

# SELECT DISTRO: (forky, sid, or exp)
SELECTED_DISTRO="sid"

case "$SELECTED_DISTRO" in
	forky)
		KERNEL_BRANCH="7.2"
		KERNEL_TAG="7.2.8-1"
		;;
	sid)
		KERNEL_BRANCH="7.2"
		KERNEL_TAG="7.2.9-1"
		;;
	exp)
		KERNEL_BRANCH="7.3"
		#KERNEL_TAG="7.2.3-1~exp1"
		KERNEL_TAG="7.3~rc6-1~exp1"
		;;
	*)
		echo "Error: Invalid selection. Choose 'forky', 'sid', or 'exp'."
		exit 1
		;;
esac

DPKG_ARCH="armhf"
CONFIG_NAME="none_armmp"

SITES=(
	"http://192.168.1.10/debian/pool/main/l/linux"
	"http://deb.debian.org/debian/pool/main/l/linux"
	"http://incoming.debian.org/debian-buildd/pool/main/l/linux"
	"http://deb.debian.org/debian-security/pool/main/l/linux"
)

DEB_FILENAME="linux-config-${KERNEL_BRANCH}_${KERNEL_TAG}_${DPKG_ARCH}.deb"
DL_DIR="./dl"
TMP_DIR="${DL_DIR}/tmp"
PATCH_DIR="./patches"

dl_deb() {
	mkdir -p "$DL_DIR" "$TMP_DIR" "$PATCH_DIR"
	local downloaded=false

	echo "Targeting [$SELECTED_DISTRO]: $DEB_FILENAME"

	for site in "${SITES[@]}"; do
		if [[ ! -f "$DL_DIR/$DEB_FILENAME" ]]; then
			wget -cq --directory-prefix="$DL_DIR" "${site}/${DEB_FILENAME}"
		fi

		if [[ -f "$DL_DIR/$DEB_FILENAME" ]]; then
			downloaded=true
			break
		fi
	done

	if [ "$downloaded" = true ]; then
		echo "[Found: $DEB_FILENAME]"
		dpkg -x "$DL_DIR/$DEB_FILENAME" "$TMP_DIR/"

		local target_config="$TMP_DIR/usr/src/linux-config-${KERNEL_BRANCH}/config.${DPKG_ARCH}_${CONFIG_NAME}.xz"

		if [[ -f "$target_config" ]]; then
			echo "Extracting config to $PATCH_DIR/debian.config..."
			xzcat -v "$target_config" > "$PATCH_DIR/debian.config"
		else
			echo "Error: Config file not found in package!"
			tree "$TMP_DIR/usr/src/linux-config-${KERNEL_BRANCH}/"
			exit 2
		fi
	else
		echo "Error: [$DEB_FILENAME] NOT FOUND in any mirrors."
		exit 3
	fi
}

dl_deb
rm -rf "$DL_DIR"

#
