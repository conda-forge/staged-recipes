#!/usr/bin/env bash
set -ex

meson_options=(
   "--prefix=${PREFIX}"
   "--libdir=lib"
   "--buildtype=release"
   "--warnlevel=0"
   ".."
)

# Enter Python subtree for out-of-tree build of Python API
pushd python

mkdir -p _build
pushd _build

meson "${meson_options[@]}"

ninja install
popd
