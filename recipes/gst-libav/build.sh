#!/usr/bin/env bash
set -ex

mkdir -p build
pushd build

meson_options=(
      -Dexamples=disabled
      -Dtests=disabled
)

meson --prefix=${PREFIX} \
      --buildtype=release \
      --libdir=$PREFIX/lib \
      --wrap-mode=nofallback \
      "${meson_options[@]}" \
      ..
ninja -j${CPU_COUNT}
ninja install

popd
