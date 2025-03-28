#!/bin/bash
set -xeo pipefail

rm -f subprojects/gtest.wrap
meson setup build ${MESON_ARGS} \
     -Dpipelines=rpi/vc4,rpi/pisp \
     -Dipas=rpi/vc4,rpi/pisp \
     -Dv4l2=true \
     -Dgstreamer=enabled \
     -Dtest=false \
     -Dlc-compliance=disabled \
     -Dcam=disabled \
     -Dqcam=disabled \
     -Ddocumentation=disabled \
     -Dpycamera=enabled \
     -Dc_args="-Wno-unused-parameter" \
     -Dcpp_args="-Wno-unused-parameter"
# the latter two are needed to avoid build errors with GCC,
# see https://github.com/raspberrypi/libpisp/pull/43
ninja -C build install
