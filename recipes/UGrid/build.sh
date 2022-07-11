#!/bin/sh

mkdir build && pushd build
cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CXX_STANDARD=17 \
    -D netCDFCxx_DIR=${PREFIX}/lib/cmake/netCDF \
    ${SRC_DIR}

make
ctest
make install
