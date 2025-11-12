#!/bin/bash

set -ex

pushd rtsp_server

mkdir build
pushd build

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig
EXTRA_FLAGS="-Dintrospection=enabled"
if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
  # Use Meson cross-file flag to enable cross compilation
  EXTRA_FLAGS="--cross-file $BUILD_PREFIX/meson_cross_file.txt -Dintrospection=disabled"
fi

export PKG_CONFIG=$(which pkg-config)

meson_options=(
      -Dexamples=disabled
      -Dtests=disabled
)

meson --prefix=${PREFIX} \
      --libdir=$PREFIX/lib \
      --buildtype=release \
      $EXTRA_FLAGS \
      --wrap-mode=nofallback \
      "${meson_options[@]}" \
      ..
ninja -j${CPU_COUNT}
ninja install
