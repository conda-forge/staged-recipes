#!/bin/bash
set -ex

mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DPYTHON_EXECUTABLE="${PYTHON}" \
    -DPYTHON_INCLUDE_DIR="${PREFIX}/include" \
    -DPYTHON_LIBRARY="$PREFIX/lib/libpython${PY_VER}.so" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_CXX_COMPILER="${GXX}" \
    -DCMAKE_CC_COMPILER="${GCC}" \
    ..

make -j${CPU_COUNT}

make install
