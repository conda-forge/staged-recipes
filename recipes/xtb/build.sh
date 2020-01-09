#!/usr/bin/env bash
set -ex

mkdir -p _build
pushd _build
meson \
   --prefix=$PREFIX \
   --libdir=$PREFIX/lib \
   --buildtype=release \
   --strip \
   -Dla_backend=openblas \
   ..
ninja
ninja -v install
