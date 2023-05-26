#!/bin/bash
set -e

mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=Release -DWITH_EXT_SHAPELIB=ON $SRC_DIR

make -j${CPU_COUNT}

install ./src/apps/dggrid/dggrid $PREFIX/bin/dggrid

