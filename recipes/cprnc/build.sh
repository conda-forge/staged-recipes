#!/usr/bin/env bash

set -x
set -e

mkdir build
cd build
cmake \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
  -D NETCDF_PATH="${PREFIX}" \
  -D CMAKE_BUILD_TYPE=Release \
  ..
cmake --build .
cmake --install .
cd ..
