#!/usr/bin/env bash
set -ex

meson_options=(
   "--prefix=${PWD}"
   "--libdir=xtb"
   "--buildtype=release"
   "--warnlevel=0"
   "--default-library=shared"
   "-Dla_backend=netlib"
   ".."
)

mkdir -p _build
pushd _build

meson "${meson_options[@]}"

ninja install
popd

"$PYTHON" -m pip install . --no-deps -vvv
