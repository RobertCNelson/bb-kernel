#!/bin/sh -e

# SPDX-FileCopyrightText: 2012 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD

if [ ! -f "${DIR}/patches/bisect_defconfig" ] ; then
	cp "${DIR}/patches/defconfig" "${DIR}/patches/bisect_defconfig"
fi

cp -v "${DIR}/patches/bisect_defconfig" "${DIR}/patches/defconfig"

cd "${DIR}/KERNEL/" || exit
git bisect start
#git bisect good v3.4
#git bisect bad v3.5-rc1


git describe
cd "${DIR}/" || exit
