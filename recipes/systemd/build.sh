#!/usr/bin/env bash
set -ex

meson configure \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --buildtype=release
meson install
meson test


