#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
    -DPython_FIND_STRATEGY="LOCATION" \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DPYCLINGOLPX_ENABLE="require" \
    -DPYCLINGOLPX_INSTALL_DIR="${SP_DIR}" \
    -DCLINGOLPX_MANAGE_RPATH=Off \
    -DCMAKE_BUILD_TYPE=Release

make -j${CPU_COUNT}
make install
