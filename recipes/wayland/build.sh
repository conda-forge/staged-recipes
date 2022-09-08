#!/bin/sh
set -x
set -e
set -u

# Bare bones development headers and libraries
meson build \
    -Ddocumentation=false \
    -Dtests=false \
    -Ddtd_validation=false \
    --prefix=${PREFIX}
ninja -C build install

