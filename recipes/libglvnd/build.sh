#! /bin/bash

set -ex

# get meson to find pkg-config when cross compiling
export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

meson ${MESON_ARGS} builddir --prefix=$PREFIX
meson configure builddir
ninja -v -C builddir
ninja -C builddir install
