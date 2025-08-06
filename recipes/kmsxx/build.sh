#!/bin/bash
set -ex

meson setup build \
  --prefix=$PREFIX \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=auto

ninja -C build
ninja -C build install
