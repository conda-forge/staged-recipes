#!/bin/bash

set -ex

# strip std settings from conda
CXXFLAGS="${CXXFLAGS/-std=c++14/}"
CXXFLAGS="${CXXFLAGS/-std=c++11/}"
export CXXFLAGS

rm -rf build && mkdir build &&  cd build
LDFLAGS="$LDFLAGS -Wl,-rpath-link,$CONDA_PREFIX/lib -pthread -lpthread" \
  cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  ..

make -j $CPU_COUNT ${VERBOSE_CM}
make install

