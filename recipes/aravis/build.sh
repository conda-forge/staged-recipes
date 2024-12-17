#!/usr/bin/env bash

export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config
export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig


meson setup ${MESON_ARGS} \
      --prefix="${PREFIX}" \
      -Dviewer=enabled \
      builddir .

meson configure builddir

ninja -C builddir -j${CPU_COUNT}
ninja -C builddir install
