#!/usr/bin/env bash
set -eu

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DAMPGEN_ROOT="${PREFIX}/share/ampgen" \
    ..

make -j${CPU_COUNT}
make install