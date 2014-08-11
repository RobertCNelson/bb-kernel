#!/bin/sh
#
# Copyright (c) 2009-2014 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Split out, so build_kernel.sh and build_deb.sh can share..

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi

git="git am"
#git_patchset=""
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="git apply"
fi

echo "Starting patch.sh"

git_add () {
	git add .
	git commit -a -m 'testing patchset'
}

start_cleanup () {
	git="git am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		git format-patch -${number} -o ${DIR}/patches/
	fi
	exit
}

external_git () {
	git_tag=""
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

#external_git
#local_patch

pinmux () {
	echo "dir: pinmux"
	${git} "${DIR}/patches/pinmux/0001-am335x-bone-split-out-pinmux.patch"
	${git} "${DIR}/patches/pinmux/0002-am335x-boneblack-split-out-emmc.patch"
	${git} "${DIR}/patches/pinmux/0003-am335x-boneblack-split-out-hdmi.patch"
	${git} "${DIR}/patches/pinmux/0004-am335x-boneblack-add-cpu0-opp-points.patch"
	${git} "${DIR}/patches/pinmux/0005-am335x-bone-eeprom-and-i2c2.patch"
	${git} "${DIR}/patches/pinmux/0006-am335x-bone-pinmux-add-uarts.patch"
	${git} "${DIR}/patches/pinmux/0007-capes-ttyO1-ttyO2-ttyO4-bone-ttyO5.patch"
	${git} "${DIR}/patches/pinmux/0008-am335x-bone-pinmux-add-spi0.patch"
	${git} "${DIR}/patches/pinmux/0009-cape-basic-proto-cape.patch"
}

sgx () {
	echo "dir: sgx"
#	${git} "${DIR}/patches/sgx/0001-reset-Add-driver-for-gpio-controlled-reset-pins.patch"
#	${git} "${DIR}/patches/sgx/0002-prcm-port-from-ti-linux-3.12.y.patch"
	${git} "${DIR}/patches/sgx/0003-ARM-DTS-AM335x-Add-SGX-DT-node.patch"
	${git} "${DIR}/patches/sgx/0004-arm-Export-cache-flush-management-symbols-when-MULTI.patch"
#	${git} "${DIR}/patches/sgx/0005-hack-port-da8xx-changes-from-ti-3.12-repo.patch"
#	${git} "${DIR}/patches/sgx/0006-Revert-drm-remove-procfs-code-take-2.patch"
	${git} "${DIR}/patches/sgx/0007-Changes-according-to-TI-for-SGX-support.patch"
}

static_capes () {
	echo "dir: static-capes"
	${git} "${DIR}/patches/static-capes/0001-Added-Argus-UPS-cape-support.patch"
	${git} "${DIR}/patches/static-capes/0002-Added-Argus-UPS-cape-support-BBW.patch"
	${git} "${DIR}/patches/static-capes/0003-ARM-dts-am335x-boneblack-cape-audi.patch"
	${git} "${DIR}/patches/static-capes/0004-Updated-dts-to-be-in-line-with-3.16-changes.patch"
}

sgx () {
	echo "dir: sgx"
	${git} "${DIR}/patches/sgx/0001-HACK-drm-fb_helper-enable-panning-support.patch"
	${git} "${DIR}/patches/sgx/0002-HACK-drm-tilcdc-add-vsync-callback-for-use-in-omaplf.patch"
	${git} "${DIR}/patches/sgx/0003-drm-tilcdc-fix-the-ping-pong-dma-tearing-issue-seen-.patch"
	${git} "${DIR}/patches/sgx/0004-ARM-OMAP2-Use-pdata-quirks-for-sgx-deassert_hardrese.patch"
	${git} "${DIR}/patches/sgx/0005-ARM-dts-am33xx-add-DT-node-for-gpu.patch"
	${git} "${DIR}/patches/sgx/0006-arm-Export-cache-flush-management-symbols-when-MULTI.patch"
}

rt () {
	echo "dir: rt"
	${git} "${DIR}/patches/rt/0001-rt-3.14-patchset.patch"
}

###
pinmux
static_capes
sgx

#disabled by default
#rt

packaging_setup () {
	cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
	git commit -a -m 'packaging: sync with mainline' -s

	git format-patch -1 -o "${DIR}/patches/packaging"
}

packaging () {
	echo "dir: packaging"
	#${git} "${DIR}/patches/packaging/0001-packaging-sync-with-mainline.patch"
	${git} "${DIR}/patches/packaging/0002-deb-pkg-install-dtbs-in-linux-image-package.patch"
	#${git} "${DIR}/patches/packaging/0003-deb-pkg-no-dtbs_install.patch"
}

#packaging_setup
packaging
echo "patch.sh ran successful"
