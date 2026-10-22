#!/bin/sh -e

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD
git_bin=$(which git)

if [ -e ${DIR}/version.sh ]; then
	./tools/get_vulnerability.sh

	FILE="known_vulnerabilities.md"

	KERNEL=$(grep "Kernel Version:" "$FILE" | awk '{print $3}')
	DATE=$(grep "Date:" "$FILE" | awk '{print $2}')

	MSG="Vulnerabilities: $KERNEL | $DATE"

	unset BRANCH
	. ${DIR}/version.sh

	if [ ! "${BRANCH}" ] ; then
		BRANCH="master"
	fi

	${git_bin} commit -a -m "$MSG" -s

	${git_bin} push origin ${BRANCH}
fi

