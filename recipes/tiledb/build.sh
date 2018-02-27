#!/bin/sh
mkdir build && cd build
CXXFLAGS="-Wno-error=unused-parameter $CXXFLAGS" cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release ..
make -j${CPU_COUNT}
make install
make check
