#!/bin/bash
set -xeo pipefail

rm -f subprojects/gtest.wrap
meson setup build ${MESON_ARGS} \
     -Ddocumentation=disabled \
     -Dtest=false
ninja -C build install
