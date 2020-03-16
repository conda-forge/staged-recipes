#!/usr/bin/env bash
set -ex

meson_options=(
   "--prefix=${PREFIX}"
   "--libdir=lib"
   "--buildtype"
   "release"
   "--warnlevel"
   "0"
   "-Dbuild_name=conda-forge"
   "-Dla_backend=netlib"
   ".."
)

mkdir -p _build
pushd _build

if [[ "$(uname)" = Darwin ]]; then
    # Hack around issue, see contents of fake-bin/cc1 for an explanation
    PATH=${PATH}:${RECIPE_DIR}/fake-bin meson "${meson_options[@]}"
else
    meson "${meson_options[@]}"
fi

ninja install
