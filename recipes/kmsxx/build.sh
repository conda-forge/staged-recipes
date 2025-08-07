#!/bin/bash
set -ex

meson setup build \
  --prefix=$PREFIX \
  --libdir=lib \
  -Dpykms=enabled \
  -Dlibutils=true \
  -Dutils=true \
  -Dkmscube=false \
  -Domap=true \
  --buildtype=release

ninja -C build
ninja -C build install
