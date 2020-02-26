#!/bin/sh

cd Cgl
mkdir build && cd build

export CXXFLAGS="${CXXFLAGS//-std=c++17/}"
export CXXFLAGS="$CXXFLAGS -std=c++11"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      $SRC_DIR/Cgl

make -j${CPU_COUNT}
make install