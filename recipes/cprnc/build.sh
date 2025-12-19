#!/usr/bin/env bash

set -x
set -e

mkdir build
cd build
cmake \
  -G Ninja \
  -DCPRNC_STANDALONE=ON \
  -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
  -D NETCDF_PATH="${PREFIX}" \
  -D NetCDF_ROOT="${PREFIX}" \
  -D NetCDF_C_ROOT="${PREFIX}" \
  -D NetCDF_Fortran_ROOT="${PREFIX}" \
  -D CMAKE_BUILD_TYPE=Release \
  ..
cmake --build .
ctest --test-dir . --output-on-failure
cmake --install .
cd ..
