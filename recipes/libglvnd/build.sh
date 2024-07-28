#!/bin/bash

set -e -x

# get meson to find pkg-config when cross compiling
export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"

meson setup builddir \
    ${MESON_ARGS} \
    --prefix="${PREFIX}" \
    -Dasm=enabled \
    -Dx11=enabled \
    -Degl=true \
    -Dglx=enabled \
    -Dgles1=true \
    -Dgles2=true \
    -Dtls=true \
    -Ddispatch-tls=true \
    -Dheaders=true
meson configure builddir
ninja -v -C builddir
ninja -C builddir install
