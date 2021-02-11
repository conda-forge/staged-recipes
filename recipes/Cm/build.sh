#!/usr/bin/env bash

set -ex

meson_config_args=(
  --prefix="$PREFIX"
  --libdir=lib
  --wrap-mode=nofallback
  --buildtype=release
  --backend=ninja
  -Dtests=false
)

mkdir forgebuild
cd forgebuild
meson setup .. "${meson_config_args[@]}"
ninja -v
ninja install
