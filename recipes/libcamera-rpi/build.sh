#!/bin/bash
set -xeuo pipefail

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
     -Dpycamera=enabled
ninja -C build install
