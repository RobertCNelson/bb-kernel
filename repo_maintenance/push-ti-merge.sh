#!/bin/sh -e

#yeah, i'm getting lazy..

wfile=$(mktemp /tmp/builder.XXXXXXXXX)
echo "Working on temp $wfile ..."

cat_files () {
	if [ -f ./patches/git/AUFS ] ; then
		cat ./patches/git/AUFS >> ${wfile}
	fi

	if [ -f ./patches/git/BBDTBS ] ; then
		cat ./patches/git/BBDTBS >> ${wfile}
	fi

	if [ -f ./patches/git/RT ] ; then
		cat ./patches/git/RT >> ${wfile}
	fi

	if [ -f ./patches/git/TI_AMX3_CM3 ] ; then
		cat ./patches/git/TI_AMX3_CM3 >> ${wfile}
	fi

	if [ -f ./patches/git/WPANUSB ] ; then
		cat ./patches/git/WPANUSB >> ${wfile}
	fi

	if [ -f ./patches/git/BCFSERIAL ] ; then
		cat ./patches/git/BCFSERIAL >> ${wfile}
	fi

	if [ -f ./patches/git/WIRELESS_REGDB ] ; then
		cat ./patches/git/WIRELESS_REGDB >> ${wfile}
	fi

	if [ -f ./patches/git/KSMBD ] ; then
		cat ./patches/git/KSMBD >> ${wfile}
	fi
}

DIR=$PWD
git_bin=$(which git)
repo="https://github.com/RobertCNelson/ti-linux-kernel/compare"

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	unset KERNEL_SHA
	. ${DIR}/version.sh

	if [ ! "${BRANCH}" ] ; then
		BRANCH="master"
	fi

	echo "merge ti: ${repo}/${ti_git_pre}...${ti_git_post}" > ${wfile}
	cat_files

	${git_bin} commit -a -F ${wfile} -s
	echo "log: git push origin ${BRANCH}"
	${git_bin} push origin ${BRANCH}
fi

echo "Deleting $wfile ..."
rm -f "$wfile"
