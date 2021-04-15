#!/usr/bin/env bash
set -eux

mkdir build
cd build

echo ${PREFIX}

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DAMPGENROOT_CMAKE="${PREFIX}" \
    ..

make -j${CPU_COUNT}
make install