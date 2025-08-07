#!/bin/bash
set -ex

export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

meson setup build \
  --prefix=$PREFIX \
  --buildtype=release \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=auto

ninja -C build
find $PREFIX -name 'libkms++util.so*'
ninja -C build install
