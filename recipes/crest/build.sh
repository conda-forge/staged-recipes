#!/usr/bin/env bash
set -ex

meson_options=(
   "--prefix=${PREFIX}"
   "--libdir=lib"
   "--buildtype=release"
   "--warnlevel=0"
   "-Dla_backend=mkl"
   "-Ddefault_library=shared"
   ".."
)

mkdir -p _build
pushd _build

meson "${meson_options[@]}"
ninja install
