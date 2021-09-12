#!/bin/sh

export CXXFLAGS="${CXXFLAGS//-std=c++17/}"
export CXXFLAGS="$CXXFLAGS -std=c++11"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -BUILD_DEPS=OFF \
      -DUSE_SCIP=OFF \
      -USE_SCIP=OFF \
      $SRC_DIR

make -j${CPU_COUNT}
make install

# run tests
make test
