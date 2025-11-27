#! /bin/bash

set -ex

export LD_LIBRARY_PATH=$PREFIX/lib

meson setup ${MESON_ARGS} \
  -Dexamples=false \
  -Ddocs=false \
  -Dintrospection=false \
  -Dvapi=false \
  -Dsmoke-tests=false \
  -Dtests=true \
  -Dc_link_args='-ldl' \
  --prefix=$PREFIX build

ninja -C build -j${CPU_COUNT}
ninja -C build install
ninja -C build test
