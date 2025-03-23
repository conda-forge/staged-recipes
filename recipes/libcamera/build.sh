#!/bin/bash
set -xeuo pipefail

rm -f subprojects/gtest.wrap
meson setup build ${MESON_ARGS}
ninja -C build install
