#!/bin/bash

# fail on first error
set -e

cd $SRC_DIR
mkdir build && cd build
cmake \
    -DBUILD_TESTS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-L$PREFIX/lib -lhdf5 -lhdf5_hl -lcurl -lnetcdf" \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_VERBOSE_MAKEFILE=OFF \
    ..

make -j
ctest
make install
