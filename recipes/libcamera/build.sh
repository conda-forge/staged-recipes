#!/bin/bash
set -xeo pipefail

rm -f subprojects/gtest.wrap
EXTRA_MESON_ARGS=""
if [[ ${variant} == "rpi" ]]; then
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dpycamera=enabled"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dpipelines=rpi/vc4,rpi/pisp"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dipas=rpi/vc4,rpi/pisp"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dv4l2=true"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dgstreamer=enabled"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dtest=false"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dlc-compliance=disabled"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dcam=disabled"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dqcam=disabled"

  # the latter two are needed to avoid build errors with GCC,
  # see https://github.com/raspberrypi/libpisp/pull/43
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dc_args=-Wno-unused-parameter"
  EXTRA_MESON_ARGS="${EXTRA_MESON_ARGS} -Dcpp_args=-Wno-unused-parameter"
fi

meson setup build ${MESON_ARGS} \
     -Ddocumentation=disabled \
     ${EXTRA_MESON_ARGS}

ninja -C build install

