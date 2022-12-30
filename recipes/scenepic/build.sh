#!/bin/bash
set -e
set -x

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCPP_TARGETS=cpp \
 -DSCENEPIC_BUILD_TESTS=ON

make -j $CPU_COUNT

make install