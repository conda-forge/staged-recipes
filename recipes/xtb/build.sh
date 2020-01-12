#!/usr/bin/env bash
set -ex

mkdir -p _build
pushd _build
meson \
   --prefix=$PREFIX \
   --libdir=lib \
   --buildtype=release \
   -Dla_backend=openblas \
   ..
ninja install
