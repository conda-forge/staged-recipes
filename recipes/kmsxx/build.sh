#!/bin/bash
set -ex

export CXXFLAGS="$CXXFLAGS -I$CONDA_BUILD_SYSROOT"

meson setup build \
  --prefix=$PREFIX \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=auto

ninja -C build
ninja -C build install
