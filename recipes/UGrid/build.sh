#!/bin/sh

mkdir build && pushd build
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D netCDFCxx_DIR=${PREFIX}/lib/cmake/netCDF \
    ${SRC_DIR}

make
ctest
make install
