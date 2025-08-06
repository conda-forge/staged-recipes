#!/bin/bash
set -ex

export SYSROOT_INCLUDE="$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/include"
export CXXFLAGS="$CXXFLAGS -I$SYSROOT_INCLUDE"

echo "Checking for dma-buf.h:"
find $BUILD_PREFIX -name dma-buf.h

meson setup build \
  --prefix=$PREFIX \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=auto

ninja -C build
ninja -C build install
