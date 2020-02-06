#!/bin/bash

mkdir build
cd build

cmake .. \
    -DCMAKE_PREFIX_PATH="${BUILD_PREFIX};${CMAKE_PREFIX_PATH}" \
    -DCMAKE_SYSTEM_IGNORE_PATH="/usr/bin;/opt/conda/bin;/usr/local/miniconda/bin;/System/Library/Frameworks/Python.framework/Versions/2.7/bin" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_LINKER="${LD}" \
    -DCMAKE_AR="${AR}" \
    -DCLINGO_REQUIRE_PYTHON=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DPYCLINGO_USER_INSTALL=OFF \
    -DCLINGO_BUILD_WITH_LUA=OFF \
    -DCLINGO_MANAGE_RPATH=OFF \
    -DPYCLINGO_INSTALL_DIR="${SP_DIR}" \
    -DCMAKE_INSTALL_LIBDIR="lib" \
    -DCMAKE_BUILD_TYPE=Release

make VERBOSE=1 -j${CPU_COUNT}
make install

