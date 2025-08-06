#!/bin/bash
set -ex

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

meson setup build \
  --prefix=$PREFIX \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=auto

ninja -C build
ninja -C build install
