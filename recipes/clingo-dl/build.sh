#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
    -DPython_FIND_STRATEGY="LOCATION" \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DPYCLINGODL_ENABLE="require" \
    -DPYCLINGODL_INSTALL_DIR="${SP_DIR}" \
    -DCLINGODL_MANAGE_RPATH=Off \
    -DCMAKE_BUILD_TYPE=Release

make -j${CPU_COUNT}
make install
