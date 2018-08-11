#!/bin/sh
#
# Copyright (c) 2009-2015 Robert Nelson <robertcnelson@gmail.com>
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

#Debian 7 (Wheezy): git version 1.7.10.4 and later needs "--no-edit"
unset git_opts
git_no_edit=$(LC_ALL=C git help pull | grep -m 1 -e "--no-edit" || true)
if [ ! "x${git_no_edit}" = "x" ] ; then
	git_opts="--no-edit"
fi

git="git am --whitespace=fix"
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
	exit 2
}

cherrypick () {
	if [ ! -d ../patches/${cherrypick_dir} ] ; then
		mkdir -p ../patches/${cherrypick_dir}
	fi
	git format-patch -1 ${SHA} --start-number ${num} -o ../patches/${cherrypick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag=""
	echo "pulling: ${git_tag}"
	git pull ${git_opts} ${git_patchset} ${git_tag}
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		git add .
		git commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		git format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}
mvebu64 () {
	echo "dir: dir"
	${git} "${DIR}/patches/mvebu64/0004-ARM64-dts-marvell-armada37xx-Enable-USB2-on-espresso.patch"
	${git} "${DIR}/patches/mvebu64/0002-arm64-dts-marvell-armada37xx-Add-eth0-alias.patch"
	${git} "${DIR}/patches/mvebu64/0008-fix-pci-aardvark-disable-LOS-state-by-default.patch"
	${git} "${DIR}/patches/mvebu64/0008-PCI-aardvark-set-host-and-device-to-the-same-MAX-pay.patch"
	${git} "${DIR}/patches/mvebu64/0010-ARM64-marvell-dts-espressobin-respin-enable-spi-i2c-.patch"
	${git} "${DIR}/patches/mvebu64/0011-espressobin-enable-emmc.patch"
	${git} "${DIR}/patches/mvebu64/1-2-clk-mvebu-armada-37xx-periph-Fix-switching-CPU-rate-from-300Mhz-to-1.2GHz.patch"
	${git} "${DIR}/patches/mvebu64/enable_ath10_cards.patch"
	${git} "${DIR}/patches/mvebu64/general-aufs4.17-20180611.patch"
	${git} "${DIR}/patches/mvebu64/general-increasing_DMA_block_memory_allocation_to_2048.patch"
	${git} "${DIR}/patches/mvebu64/general-packaging-4.17-dev.patch"
	${git} "${DIR}/patches/mvebu64/unlock_atheros_regulatory_restrictions.patch"
	${git} "${DIR}/patches/mvebu64/wifi-0001-realtek-wifi-881xAU-605ecfa.patch"
	${git} "${DIR}/patches/mvebu64/wifi-0002-realtek-wifi-881xAU-adding-kernel-4.14.patch"
	${git} "${DIR}/patches/mvebu64/wifi-0003-realtek-wifi-881xAU-enable-8814au.patch"
	${git} "${DIR}/patches/mvebu64/wifi-0005-realtek-wifi-881xAU-update-to-5a5d0f.patch"
	${git} "${DIR}/patches/mvebu64/wifi-2001-01-rtl8188eu-kconfig-makefile.patch"
	${git} "${DIR}/patches/mvebu64/wifi-2002-02-rtl8188eu.patch"
}

#external_git
#rt
#local_patch
mvebu64

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		git commit -a -m 'packaging: sync builddeb changes' -s
		git format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

#packaging
echo "patch.sh ran successfully"
