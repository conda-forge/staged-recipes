#! /bin/sh

meson \
  --prefix="${PREFIX}" \
  --libdir=lib \
  build
ninja -C build/
ninja -C build/ install
