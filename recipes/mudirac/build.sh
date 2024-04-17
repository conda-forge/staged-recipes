#!/bin/bash
mkdir -p build
cd build
cmake $CMAKE_ARGS $SRC_DIR
make -j $CPU_COUNT
ctest
mkdir -p $PREFIX/bin/
cp -r bin/mudirac $PREFIX/bin/
