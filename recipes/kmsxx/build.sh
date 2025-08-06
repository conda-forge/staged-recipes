#!/bin/bash
set -ex

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
