#!/bin/sh

export CXXFLAGS="${CXXFLAGS//-std=c++17/}"
export CXXFLAGS="$CXXFLAGS -std=c++11"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_absl=OFF \
      -DBUILD_Protobuf=OFF \
      -DBUILD_CoinUtils=OFF \
      -DBUILD_Osi=OFF \
      -DBUILD_Clp=OFF \
      -DBUILD_Cgl=OFF \
      -DBUILD_Cbc=OFF \
      -DUSE_SCIP=OFF \
      $SRC_DIR

make -j${CPU_COUNT}
make install

# run tests
make test
