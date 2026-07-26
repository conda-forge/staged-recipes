#!/bin/bash
set -ex

cmake -B build \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DNEP_BUILD_LZ4=ON \
  -DNEP_BUILD_BZIP2=OFF \
  -DNEP_ENABLE_FORTRAN=ON \
  -DNEP_ENABLE_GEOTIFF=OFF \
  -DNEP_ENABLE_GRIB2=OFF \
  -DNEP_ENABLE_FITS=OFF \
  -DNEP_ENABLE_PDS4=OFF \
  -DNEP_ENABLE_CDF=OFF \
  -DNEP_ENABLE_DICOM=OFF \
  -DNEP_BUILD_DOCUMENTATION=OFF \
  -DNEP_BUILD_EXAMPLES=OFF \
  -DNEP_ENABLE_BENCHMARKS=OFF \
  -DNEP_ENABLE_PARALLEL_TESTS=OFF

cmake --build build -- -j${CPU_COUNT}
ctest --test-dir build --output-on-failure
cmake --install build
install -m 644 build/fsrc/nep.mod "${PREFIX}/include/nep.mod"
