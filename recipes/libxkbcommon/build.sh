#!/bin/bash
set -ex

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}:${PREFIX}/lib/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/lib64/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/share/pkgconfig"
meson setup build \
  --prefix=$PREFIX \
  --libdir=$PREFIX/lib \
  -Denable-wayland=false \
  -Denable-docs=false
ninja -C build install -v
