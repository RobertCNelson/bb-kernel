#!/bin/sh
#
# Copyright (c) 2009-2013 Robert Nelson <robertcnelson@gmail.com>
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

git="git am"

if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi

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

bugs_trivial () {
echo "bugs and trivial stuff"

#Bisected from 2.6.35 -> 2.6.36 to find this..
#This commit breaks some lcd monitors..
#rcn-ee Feb 26, 2011...
#Still needs more work for 2.6.38, causes:
#[   14.962829] omapdss DISPC error: GFX_FIFO_UNDERFLOW, disabling GFX
#patch -s -p1 < "${DIR}/patches/trivial/0001-Revert-OMAP-DSS2-OMAPFB-swap-front-and-back-porches-.patch"

patch -s -p1 < "${DIR}/patches/trivial/0001-kbuild-deb-pkg-set-host-machine-after-dpkg-gencontro.patch"

#should fix gcc-4.6 ehci problems..
patch -s -p1 < "${DIR}/patches/trivial/0001-USB-ehci-use-packed-aligned-4-instead-of-removing-th.patch"

#3.1-rc3, serial broken, probally will be revert later..
#fixed with 3.1-rc4
#patch -s -p1 < "${DIR}/patches/trivial/0001-Revert-irq-Always-set-IRQF_ONESHOT-if-no-primary-han.patch"

#3.1-merge-to-v3.2-rc0

#patch -s -p1 < "${DIR}/patches/trivial/0001-ARM-OMAP-fix-omap2plus_defconfig-with-OMAP2-disabled.patch"
#patch -s -p1 < "${DIR}/patches/trivial/0001-trivial-drivers-mmc-omap-add-missing.patch"

}

cpufreq () {
echo "[git] omap-cpufreq"
git pull ${GIT_OPTS} git://github.com/RobertCNelson/linux.git omap_cpufreq_v3.1-rc8

}

am33x () {
echo "[git] am33x"
git pull ${GIT_OPTS} git://github.com/RobertCNelson/linux.git ti_am33x_v3.1

}


dss2_next () {
echo "dss2 from for-next"

}

dspbridge_next () {
echo "dspbridge from for-next"

}

omap_fixes () {
echo "omap fixes"
#fixes broken vout
#patch -s -p1 < "${DIR}/patches/trivial/0001-OMAP_VOUT-Fix-build-break-caused-by-update_mode-remo.patch"
#fixed in 3.1-rc9

}

for_next () {
echo "for_next from tmlind's tree.."

}

sakoman () {
echo "sakoman's patches"

#patch -s -p1 < "${DIR}/patches/sakoman/2.6.39/0006-OMAP-DSS2-add-bootarg-for-selecting-svideo-or-compos.patch"
#patch -s -p1 < "${DIR}/patches/sakoman/2.6.39/0007-video-add-timings-for-hd720.patch"

patch -s -p1 < "${DIR}/patches/sakoman/2.6.39/0025-omap-mmc-Adjust-dto-to-eliminate-timeout-errors.patch"
#patch -s -p1 < "${DIR}/patches/sakoman/2.6.39/0026-OMAP-Overo-Add-support-for-spidev.patch"

}

musb () {
echo "musb patches"
patch -s -p1 < "${DIR}/patches/musb/0001-default-to-fifo-mode-5-for-old-musb-beagles.patch"
}

micrel () {
echo "[git] Micrel KZ8851 patches for: zippy2"
#original from:
#ftp://www.micrel.com/ethernet/8851/beagle_zippy_patches.tar.gz 137 KB 04/10/2010 12:26:00 AM

git pull ${GIT_OPTS} git://github.com/RobertCNelson/linux.git micrel_ks8851_v3.1-rc8

}

beagle () {
echo "[git] Board Patches for: BeagleBoard"

git pull git://github.com/RobertCNelson/linux.git omap_beagle_expansion_v3.1-rc9

patch -s -p1 < "${DIR}/patches/arago-project/0001-omap3-Increase-limit-on-bootarg-mpurate.patch"
patch -s -p1 < "${DIR}/patches/display/0001-meego-modedb-add-Toshiba-LTA070B220F-800x480-support.patch"

}

igepv2 () {
echo "[git] Board Patches for: igepv2"
#pulled from: http://git.igep.es/?p=pub/scm/linux-omap-2.6.git;a=summary
#git pull git://git.igep.es/pub/scm/linux-omap-2.6.git master

git pull ${GIT_OPTS} git://github.com/RobertCNelson/linux.git omap_igepv_v3.1-rc7

}

devkit8000 () {
echo "devkit8000"
patch -s -p1 < "${DIR}/patches/devkit8000/0001-arm-omap-devkit8000-for-lcd-use-samsung_lte_panel-2.6.37-git10.patch"
}

touchbook () {
echo "touchbook patches"
patch -s -p1 < "${DIR}/patches/touchbook/0001-omap3-touchbook-remove-mmc-gpio_wp.patch"
patch -s -p1 < "${DIR}/patches/touchbook/0002-omap3-touchbook-drop-u-boot-readonly.patch"
#patch -s -p1 < "${DIR}/patches/touchbook/0001-touchbook-add-madc.patch"
#patch -s -p1 < "${DIR}/patches/touchbook/0002-touchbook-add-twl4030-bci-battery.patch"
}

dspbridge () {
echo "dspbridge fixes"
#broken in 3.0-git5
#drivers/staging/tidspbridge/core/dsp-clock.c: In function ‘dsp_clk_enable’:
#drivers/staging/tidspbridge/core/dsp-clock.c:212:3: error: implicit declaration of function ‘omap_mcbsp_set_io_type’
#drivers/staging/tidspbridge/core/dsp-clock.c:212:42: error: ‘OMAP_MCBSP_POLL_IO’ undeclared (first use in this function)
#drivers/staging/tidspbridge/core/dsp-clock.c:212:42: note: each undeclared identifier is reported only once for each function it appears in
#make[3]: *** [drivers/staging/tidspbridge/core/dsp-clock.o] Error 1
#make[2]: *** [drivers/staging/tidspbridge] Error 2
#patch -s -p1 < "${DIR}/patches/dspbridge/0001-Revert-omap-mcbsp-Remove-port-number-enums.patch"
#patch -s -p1 < "${DIR}/patches/dspbridge/0002-Revert-omap-mcbsp-Remove-rx_-tx_word_length-variable.patch"
#patch -s -p1 < "${DIR}/patches/dspbridge/0003-Revert-omap-mcbsp-Drop-in-driver-transfer-support.patch"
#fixed with 3.1-rc4
}

omap4 () {
echo "omap4 related patches"
#drop with 3.0-git16
#patch -s -p1 < "${DIR}/patches/panda/0001-OMAP4-DSS2-add-dss_dss_clk.patch"
patch -s -p1 < "${DIR}/patches/panda/0001-panda-fix-wl12xx-regulator.patch"
}

sgx () {
echo "merge in ti sgx modules"
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-3.01.00.02-Kernel-Modules.patch"
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-enable-driver-building.patch"

#3.01.00.06
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-3.01.00.06-into-TI-3.01.00.02.patch"

#3.01.00.07 'the first wget-able release!!'
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-3.01.00.07-into-TI-3.01.00.06.patch"

#4.00.00.01 adds ti8168 support, drops bc_cat.c patch
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-4.00.00.01-into-TI-3.01.00.07.patch"

#4.03.00.01
#Note: git am has problems with this patch...
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-4.03.00.01-into-TI-4.00.00.01.patch"

#4.03.00.02 (main *.bin drops omap4)
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-Merge-TI-4.03.00.02-into-TI-4.03.00.01.patch"

#4.04.00.01 (adds omap4 libs)
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-4-SGX-Merge-TI-4.04.00.01-into-TI-4.03.00.02.patch"

#4.04.00.02
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-4-SGX-Merge-TI-4.04.00.02-into-TI-4.04.00.01.patch"

#4.03.00.02
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.02-2.6.32-PSP.patch"

#4.03.00.02 + 2.6.38-merge (2.6.37-git5)
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.02-2.6.38-merge-AUTOCONF_INCLUD.patch"

#4.03.00.02 + 2.6.38-rc3
#updated for 4.04.00.01
#updated for 4.04.00.02
#use: for updating patch:
#sed -i -e 's:acquire_console_sem:console_lock:g' drivers/staging/omap3-sgx/services4/3rdparty/*/*.c
#sed -i -e 's:release_console_sem:console_unlock:g' drivers/staging/omap3-sgx/services4/3rdparty/*/*.c
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-4-SGX-TI-4.04.00.01-2.6.38-rc3-_console_sem-to-c.patch"

#4.03.00.01
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.01-add-outer_cache.clean_all.patch"

#4.03.00.02
#omap3 doesn't work on omap3630
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.02-use-omap3630-as-TI_PLATFORM.patch"

#4.03.00.02 + 2.6.39 (2.6.38-git2)
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.02-2.6.39-rc-SPIN_LOCK_UNLOCKED.patch"

#4.03.00.02 + 2.6.40 (2.6.39-git11)
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-SGX-TI-4.03.00.02-2.6.40-display.h-to-omapdss..patch"

#4.04.00.01 fix Kbuild
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-4-SGX-TI-4.04.00.01-fix-Kbuild.patch"

#4.04.00.01 fix another linux/config.h reference
patch -s -p1 < "${DIR}/patches/sgx/0001-OMAP3-4-SGX-TI-4.04.00.01-remove-config.h-reference.patch"

#with v3.0-git16
#drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c:324:15: error: ‘OMAP_DSS_UPDATE_AUTO’ undeclared (first use in this function)
#drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c:327:15: error: ‘OMAP_DSS_UPDATE_MANUAL’ undeclared (first use in this function)
#drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c:330:15: error: ‘OMAP_DSS_UPDATE_DISABLED’ undeclared (first use in this function)
#drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c:337:16: error: ‘struct omap_dss_driver’ has no member named ‘set_update_mode’
#drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c:312:28: warning: unused variable ‘eDSSMode’
#make[4]: *** [drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.o] Error 1
#make[3]: *** [drivers/staging/omap3-sgx/services4/3rdparty/dc_omapfb3_linux] Error 2
#make[2]: *** [drivers/staging/omap3-sgx] Error 2
patch -s -p1 < "${DIR}/patches/sgx/0001-Revert-OMAP-DSS2-remove-update_mode-from-omapdss.patch"

}

wifi () {
echo "wifi: update a few drivers to the latest"
patch -s -p1 < "${DIR}/patches/wifi/0001-rtlwifi-update-to-v3.2-rc6.patch"
patch -s -p1 < "${DIR}/patches/wifi/0001-wifi-changes-needed-from-v3.2-rc6.patch"
}

bugs_trivial

#patches in git
am33x

#for_next tree's
#dss2_next
#omap_fixes
#dspbridge_next
#for_next

#external tree's
sakoman

wifi

echo "patch.sh ran successful"

