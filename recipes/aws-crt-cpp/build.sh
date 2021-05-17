#!/bin/bash

set -ex

mkdir build
pushd build
cmake ${CMAKE_ARGS} -GNinja \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_DEPS=OFF \
  ..
ninja install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  ctest -E HttpDownloadNoBackPressureHTTP2
fi
popd
