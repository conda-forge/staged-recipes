#!/bin/sh

mkdir build && cd build

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -G "Ninja" \
      $SRC_DIR

ninja -v -j${CPU_COUNT}
ninja install
