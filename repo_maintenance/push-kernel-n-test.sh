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

	if [ -f ./patches/external/git/TI_AMX3_CM3 ] ; then
		cat ./patches/external/git/TI_AMX3_CM3 >> ${wfile}
	fi

	if [ -f ./patches/external/git/WPANUSB ] ; then
		cat ./patches/external/git/WPANUSB >> ${wfile}
	fi

	if [ -f ./patches/external/git/BCFSERIAL ] ; then
		cat ./patches/external/git/BCFSERIAL >> ${wfile}
	fi
}

DIR=$PWD
git_bin=$(which git)

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	unset KERNEL_TAG
	. ${DIR}/version.sh

	if [ ! "${BRANCH}" ] ; then
		BRANCH="master"
	fi

	if [ ! "${KERNEL_TAG}" ] ; then
		echo 'KERNEL_TAG undefined'
		exit
	fi

	if [ -f ./patches/external/git/RT ] ; then
		echo "kernel v${KERNEL_TAG}${BUILD} rebase external git projects and rt: v${KERNEL_REL}${kernel_rt}" > ${wfile}
	else
		echo "kernel v${KERNEL_TAG}${BUILD} rebase external git projects" > ${wfile}
	fi
	if [ "${TISDK}" ] ; then
		echo "TI SDK: ${TISDK}" >> ${wfile}
	fi
	cat_files

	${git_bin} commit -a -F ${wfile} -s
	echo "log: git push origin ${BRANCH}"
	${git_bin} push origin ${BRANCH}
fi

echo "Deleting $wfile ..."
rm -f "$wfile"

