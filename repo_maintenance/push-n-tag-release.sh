#!/bin/sh -e

#yeah, i'm getting lazy..

wfile=$(mktemp /tmp/builder.XXXXXXXXX)
echo "Working on temp $wfile ..."

cat_files () {
	if [ -f ./patches/external/git/BBDTBS ] ; then
		cat ./patches/external/git/BBDTBS >> ${wfile}
	fi

	if [ -f ./patches/external/git/RT ] ; then
		cat ./patches/external/git/RT >> ${wfile}
	fi

	if [ -f ./patches/external/git/WIRELESS_REGDB ] ; then
		cat ./patches/external/git/WIRELESS_REGDB >> ${wfile}
	fi

	if [ -f ./patches/external/git/KSMBD ] ; then
		cat ./patches/external/git/KSMBD >> ${wfile}
	fi

	if [ -f ./patches/external/git/TI_AMX3_CM3 ] ; then
		cat ./patches/external/git/TI_AMX3_CM3 >> ${wfile}
	fi
}

DIR=$PWD
git_bin=$(which git)

repo="git@gitlab.gfnd.rcn-ee.org:production/linux-stable-rcn-ee.git"
example="rcn-ee"

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	. ${DIR}/version.sh

	echo "${KERNEL_TAG}${BUILD} release" > ${wfile}
	cat_files

	${git_bin} commit -a -F ${wfile} -s
	${git_bin} tag -a "${KERNEL_TAG}${BUILD}" -m "${KERNEL_TAG}${BUILD}" -f

	${git_bin} push -f origin ${BRANCH}
	${git_bin} push -f origin ${BRANCH} --tags

	cd ${DIR}/KERNEL/
	make ARCH=${KERNEL_ARCH} distclean

	cp ${DIR}/patches/defconfig ${DIR}/KERNEL/.config
	make ARCH=${KERNEL_ARCH} savedefconfig
	cp ${DIR}/KERNEL/defconfig ${DIR}/KERNEL/arch/${KERNEL_ARCH}/configs/${example}_defconfig
	${git_bin} add arch/${KERNEL_ARCH}/configs/${example}_defconfig

	echo "${KERNEL_TAG}${BUILD} ${example}_defconfig" > ${wfile}
	cat_files

	${git_bin} commit -a -F ${wfile} -s
	${git_bin} tag -a "${KERNEL_TAG}${BUILD}" -m "${KERNEL_TAG}${BUILD}" -f

	#push tag
	echo "log: git push -f ${repo} \"${KERNEL_TAG}${BUILD}\""
	${git_bin} push -f ${repo} "${KERNEL_TAG}${BUILD}"

	cd ${DIR}/
fi

echo "Deleting $wfile ..."
rm -f "$wfile"

