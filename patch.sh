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

meson64 () {
	echo "dir: meson64"
	${git} "${DIR}/patches/meson64/0001-ARM64-defconfig-enable-CEC-support.patch"
	${git} "${DIR}/patches/meson64/0002-ASoC-meson-add-meson-audio-core-driver.patch"
	${git} "${DIR}/patches/meson64/0003-ASoC-meson-add-register-definitions.patch"
	${git} "${DIR}/patches/meson64/0004-ASoC-meson-add-aiu-i2s-dma-support.patch"
	${git} "${DIR}/patches/meson64/0005-ASoC-meson-add-initial-i2s-dai-support.patch"
	${git} "${DIR}/patches/meson64/0006-ASoC-meson-add-aiu-spdif-dma-support.patch"
	${git} "${DIR}/patches/meson64/0007-ASoC-meson-add-initial-spdif-dai-support.patch"
	${git} "${DIR}/patches/meson64/0008-ARM64-defconfig-enable-audio-support-for-meson-SoCs-.patch"
	${git} "${DIR}/patches/meson64/0009-ARM64-dts-meson-gx-add-audio-controller-nodes.patch"
	${git} "${DIR}/patches/meson64/0010-snd-meson-activate-HDMI-audio-path.patch"
	${git} "${DIR}/patches/meson64/0011-drm-meson-select-dw-hdmi-i2s-audio-for-meson-hdmi.patch"
	${git} "${DIR}/patches/meson64/0012-ARM64-dts-meson-gx-add-sound-dai-cells-to-HDMI-node.patch"
	${git} "${DIR}/patches/meson64/0013-ARM64-dts-meson-activate-hdmi-audio-HDMI-enabled-boa.patch"
	${git} "${DIR}/patches/meson64/0014-drm-bridge-dw-hdmi-Use-AUTO-CTS-setup-mode-when-non-.patch"
	${git} "${DIR}/patches/meson64/0017-soc-amlogic-add-meson-canvas-driver.patch"
	${git} "${DIR}/patches/meson64/0018-ARM64-dts-meson-gx-add-dmcbus-and-canvas-nodes.patch"
	${git} "${DIR}/patches/meson64/0020-drm-meson-Use-optional-canvas-provider.patch"
	${git} "${DIR}/patches/meson64/0021-arm64-dts-meson-gx-Add-canvas-provider-node-to-the-v.patch"
	${git} "${DIR}/patches/meson64/0022-drm-meson-Support-Overlay-plane-for-video-rendering.patch"
	${git} "${DIR}/patches/meson64/0023-drm-meson-move-OSD-scaler-management-into-plane-atom.patch"
	${git} "${DIR}/patches/meson64/0024-drm-meson-Add-primary-plane-scaling.patch"
	${git} "${DIR}/patches/meson64/0026-pinctrl-meson-gxl-remove-invalid-GPIOX-tsin_a-pins.patch"
	${git} "${DIR}/patches/meson64/0027-arm64-dts-meson-gx-Add-hdmi_5v-regulator-as-hdmi-tx-.patch"
	${git} "${DIR}/patches/meson64/0028-arm64-dts-meson-gxl-libretech-cc-fix-GPIO-lines-name.patch"
	${git} "${DIR}/patches/meson64/0029-arm64-dts-meson-gxbb-nanopi-k2-fix-GPIO-lines-names.patch"
	${git} "${DIR}/patches/meson64/0030-arm64-dts-meson-gxbb-odroidc2-fix-GPIO-lines-names.patch"
	${git} "${DIR}/patches/meson64/0031-arm64-dts-meson-gxl-khadas-vim-fix-GPIO-lines-names.patch"
	${git} "${DIR}/patches/meson64/0032-drm-meson-Add-support-for-VIC-alternate-timings.patch"
	${git} "${DIR}/patches/meson64/0033-media-meson-add-v4l2-m2m-video-decoder-driver.patch"
	${git} "${DIR}/patches/meson64/0034-MAINTAINERS-Add-meson-video-decoder.patch"
	${git} "${DIR}/patches/meson64/0035-arm64-dts-meson-gx-add-vdec-entry.patch"
	${git} "${DIR}/patches/meson64/0036-arm64-dts-meson-add-vdec-entries.patch"
	${git} "${DIR}/patches/meson64/0037-meson-vdec-introduce-controls-and-V4L2_CID_MIN_BUFFE.patch"
	${git} "${DIR}/patches/meson64/0038-media-videodev2-add-V4L2_FMT_FLAG_NO_SOURCE_CHANGE.patch"
	${git} "${DIR}/patches/meson64/0039-meson-vdec-allow-subscribing-to-V4L2_EVENT_SOURCE_CH.patch"
	${git} "${DIR}/patches/meson64/0040-media-meson-vdec-add-H.264-decoding-support.patch"
	${git} "${DIR}/patches/meson64/0041-media-meson-vdec-add-MPEG4-decoding-support.patch"
	${git} "${DIR}/patches/meson64/0042-media-meson-vdec-add-MJPEG-decoding-support.patch"
	${git} "${DIR}/patches/meson64/0043-clk-meson-gxbb-set-fclk_div3-as-CLK_IS_CRITICAL.patch"
	${git} "${DIR}/patches/meson64/0008-drm-meson-Add-HDMI-1.4-4k-modes.patch"
	${git} "${DIR}/patches/meson64/0009-drm-meson-Use-drm_fbdev_generic_setup.patch"
	${git} "${DIR}/patches/meson64/0010-fixup-drm-meson-Use-optional-canvas-provider.patch"
	${git} "${DIR}/patches/meson64/0014-drm-bridge-dw-hdmi-Add-SCDC-and-TMDS-Scrambling-supp.patch"
	${git} "${DIR}/patches/meson64/0015-drm-meson-add-HDMI-div40-TMDS-mode.patch"
	${git} "${DIR}/patches/meson64/0016-drm-meson-add-support-for-HDMI2.0-2160p-modes.patch"
	${git} "${DIR}/patches/meson64/0017-drm-bridge-dw-hdmi-add-support-for-YUV420-output.patch"
	${git} "${DIR}/patches/meson64/0018-drm-bridge-dw-hdmi-support-dynamically-get-input-out.patch"
	${git} "${DIR}/patches/meson64/0019-drm-bridge-dw-hdmi-allow-ycbcr420-modes-for-0x200a.patch"
	${git} "${DIR}/patches/meson64/0020-drm-meson-Add-YUV420-output-support.patch"
	${git} "${DIR}/patches/meson64/0021-drm-meson-Output-in-YUV444-if-sink-supports-it.patch"
	${git} "${DIR}/patches/meson64/0023-drm-meson-Fix-an-Alpha-Primary-Plane-bug-on-Meson-GX.patch"
}

#external_git
#rt
#local_patch
#meson64

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
