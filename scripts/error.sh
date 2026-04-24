#!/bin/sh -e

# SPDX-FileCopyrightText: 2013 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD

#Yuck, this error script can be called two directories...
offset="/"
if [ -f "${DIR}/../version.sh" ] ; then
	. "${DIR}/../version.sh"
	offset="../"
fi
if [ -f "${DIR}/../../version.sh" ] ; then
	. "${DIR}/../../version.sh"
	offset="../../"
fi

echo "-----------------------------"
echo "Script Error: please cut and paste the following into an email to: bugs@rcn-ee.com"
echo "**********************************************************"
echo "Error: [${ERROR_MSG}]"

if [ -f "${DIR}/${offset}.git/config" ] ; then
	gitrepo=$(cat "${DIR}/${offset}.git/config" | grep url | awk '{print $3}')
	gitwhatchanged=$(cd ${offset} || exit ; git whatchanged -1)
	echo "git repo: [${gitrepo}]"
	echo "-----------------------------"
	echo "${gitwhatchanged}"
	echo "-----------------------------"
else
	if [ "${BRANCH}" ] ; then
		echo "nongit: [${BRANCH}]"
	else
		echo "nongit: [master]"
	fi
fi

if [ ! "${KERNEL_SHA}" ] ; then
	echo "kernel: [v${KERNEL_TAG}${BUILD}]"
else
	echo "kernel: [v${KERNEL_TAG}${BUILD}] + [${KERNEL_SHA}]"
fi

echo "uname -m"
uname -m
if [ "$(which lsb_release)" ] ; then
	echo "lsb_release -a"
	lsb_release -a
fi
echo "**********************************************************"

