#!/usr/bin/env bash
set -ex

meson_options=(
   "--prefix=${PREFIX}"
   "--libdir=lib"
   "--buildtype=release"
   "--default-library=shared"
   "--warnlevel=0"
   "-Dla_backend=netlib"
   ".."
)

mkdir -p _build
pushd _build

meson "${meson_options[@]}"

ninja test install
