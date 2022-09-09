#!/bin/sh
set -x
set -e
set -u

# Bare bones development headers and libraries
meson build \
    -Ddocumentation=false \
    -Dtests=false \
    -Ddtd_validation=false \
    --prefix=${PREFIX} \
    -Dlibdir=lib \
    ${MESON_ARGS}
ninja -C build install

