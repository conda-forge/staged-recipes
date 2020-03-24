#!/usr/bin/env bash
set -exu

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DWITH_PYTHON=ON \
    -DWITH_ROOT=ON \
    -DWITH_EXAMPLES=ON \
    -DWITH_EXAMPLES_EXTRA=OFF \
    -DENABLE_TESTS=ON \
    -DBUILD_DOCUMENTATION=OFF \
    -DINSTALL_EXTERNAL_DEPENDENCIES=OFF \
    -DFORCE_YAMLCPP_INSTALL=OFF \
    -DFORCE_HEPMC_INSTALL=OFF \
    -DMAX_CXX_IS_14=OFF \
    -DPython3_EXECUTABLE="$PYTHON" \
    ..

make -j${CPU_COUNT}

ctest -V

make install
