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

git="git am --3way --whitespace=fix"
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

toolchain () {
	echo "dir: toolchain"
	${git} "${DIR}/patches/toolchain/0001-arch-arm64-kernel-vdso-Makefile-fix-gold-linker-fail.patch"
}

bootsplash () {
        echo "dir: bootsplash"
	${git} "${DIR}/patches/bootsplash/0001-linux-stable-Add-kernel-bootsplash-patches.patch"
	${git} "${DIR}/patches/bootsplash/0002-bootsplash-add-gentoo-logo-build-script.patch"
	${git} "${DIR}/patches/bootsplash/0003-tools-bootsplash-Makefile-fix-include-paths.patch"
}

drivers () {
	echo "dir: drivers/sun8i-ce"
	${git} "${DIR}/patches/drivers/sun8i-ce/0001-crypto-Add-allwinner-subdirectory.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0002-crypto-Add-Allwinner-sun8i-ce-Crypto-Engine.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0003-dt-bindings-crypto-Add-DT-bindings-documentation-for.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0004-ARM-dts-sun8i-r40-add-crypto-engine-node.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0005-ARM-dts-sun8i-h3-Add-Crypto-Engine-node.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0006-ARM64-dts-allwinner-sun50i-Add-Crypto-Engine-node-on.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0007-ARM64-dts-allwinner-sun50i-Add-crypto-engine-node-on.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0008-ARM64-dts-allwinner-sun50i-Add-Crypto-Engine-node-on.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0009-sunxi_defconfig-add-new-crypto-options.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0010-crypto-Add-Allwinner-sun8i-ss-cryptographic-offloade.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0011-dt-bindings-crypto-Add-DT-bindings-documentation-for.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0012-ARM-dts-sun8i-a83t-Add-Security-System-node.patch"
	${git} "${DIR}/patches/drivers/sun8i-ce/0013-ARM-dts-sun9i-a80-Add-Security-System-node.patch"
}

rtl8723cs () {
	echo "dir: drivers/rtl8723cs"
	${git} "${DIR}/patches/drivers/rtl8723cs/0015-drivers-net-wireless-realtek-add-rtl8723cs-support-f.patch"
	${git} "${DIR}/patches/drivers/rtl8723cs/0016-drivers-net-wireless-realtek-add-rtl8723cs-support-f.patch"
	${git} "${DIR}/patches/drivers/rtl8723cs/0030-rtl8723cs-add-use-of-ktime_get_boottime_ts64-for-ker.patch"
}

usb_phy () {
	echo "dir: usb_phy"
	${git} "${DIR}/patches/meson64/0001-ARM64-dts-meson-gxbb-odroidc2-Fix-usb-phy-reset-warning.patch"
	${git} "${DIR}/patches/meson64/0002-ARM64-dts-meson-gxbb-odroidc2-Fix-usb-phy-regulator-power-failed-warning.patch"
}

allwinner () {
	echo "dir: allwinner"
	${git} "${DIR}/patches/allwinner/0020-hdmi-audio-fixup.patch"
	${git} "${DIR}/patches/allwinner/0021-Bluetooth-Add-new-quirk-for-broken-local-ext-feature.patch"
	${git} "${DIR}/patches/allwinner/0022-Bluetooth-hci_h5-Add-support-for-reset-GPIO.patch"
	${git} "${DIR}/patches/allwinner/0023-dt-bindings-net-bluetooth-Add-rtl8723bs-bluetooth.patch"
	${git} "${DIR}/patches/allwinner/0024-Bluetooth-hci_h5-Add-support-for-binding-RTL8723BS-w.patch"
	${git} "${DIR}/patches/allwinner/0025-Bluetooth-btrtl-add-support-for-the-RTL8723CS.patch"
	${git} "${DIR}/patches/allwinner/0026-arm64-allwinner-a64-enable-Bluetooth-On-Pinebook.patch"
	${git} "${DIR}/patches/allwinner/0027-arm64-allwinner-a64-enable-Bluetooth-On-Pine64.patch"
	${git} "${DIR}/patches/allwinner/0028-arm64-allwinner-a64-enable-Bluetooth-On-SoPine-baseb.patch"
	${git} "${DIR}/patches/allwinner/0029-si2168-fix-cmd-timeout.patch"
	${git} "${DIR}/patches/allwinner/0031-dts-a64-ths.patch"
#	${git} "${DIR}/patches/allwinner/0032-a64-dvfs-wip.patch"
}

pinebook () {
	echo "dir: pinebook"
	${git} "${DIR}/patches/pinebook/0001-ARCH-arm64-dts-sun50i-a64-enable-pinebook-backlight.patch"
#	${git} "${DIR}/patches/pinebook/0001-arm64-dts-allwinner-a64-Enable-HDMI-output-on-A64-bo.patch"
#	${git} "${DIR}/patches/pinebook/0002-arm64-allwinner-a64-enable-ANX6345-bridge-on-Pineboo.patch"
}

chromebook () {
	echo "dir: chromebook"
	${git} "${DIR}/patches/chromebook/0001-drm-bridge-GPIO-controlled-display-multiplexer-drive.patch"
#	${git} "${DIR}/patches/chromebook/RFC-v2-1-8-drm-bridge-GPIO-controlled-display-multiplexer-driver.patch"
	${git} "${DIR}/patches/chromebook/RFC-v2-2-8-platform-chrome-ChromeOS-firmware-interface-driver.patch"
	${git} "${DIR}/patches/chromebook/0001-drm-bridge-Parade-PS8640-MIPI-DSI-eDP-converter-driv.patch"
#	${git} "${DIR}/patches/chromebook/RFC-v2-3-8-drm-bridge-Parade-PS8640-MIPI-DSI---eDP-converter-driver.patch"
	${git} "${DIR}/patches/chromebook/RFC-v2-4-8-drm-bridge-Analogix-ANX7688-HDMI---DP-bridge-driver.patch"
	${git} "${DIR}/patches/chromebook/0001-arm64-dts-mediatek-Add-Elm-Rev.-3-device-tree.patch"
#	${git} "${DIR}/patches/chromebook/RFC-v2-5-8-arm64-dts-mediatek-Add-Elm-Rev.-3-device-tree.patch"
	${git} "${DIR}/patches/chromebook/RFC-v2-6-8-hack-mediatek-get-mmsys-to-register-as-both-DRM-and-clock-device.patch"
	${git} "${DIR}/patches/chromebook/0001-RFC-v2-7-8-drm-mediatek-Add-DRM-based-framebuffer-de.patch"
#	${git} "${DIR}/patches/chromebook/RFC-v2-7-8-drm-mediatek-Add-DRM-based-framebuffer-device.patch"
	${git} "${DIR}/patches/chromebook/RFC-v2-8-8-drm-mediatek-Fix-drm_of_find_panel_or_bridge-conversion.patch"
	${git} "${DIR}/patches/chromebook/0001-drm-mediatek-cleanup-mtk_drm_fbdev-based-on-patchwor.patch"
}

#external_git
#rt
#local_patch
#toolchain
bootsplash
#drivers
rtl8723cs
#usb_phy
#allwinner
pinebook
#chromebook

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
