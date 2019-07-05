#!/usr/bin/env bash
set -ex

mkdir -p build
meson \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --buildtype=release \
  ..
meson install
meson test


