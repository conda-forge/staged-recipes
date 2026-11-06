#!/bin/bash
set -euxo pipefail

# 4.2.0 cannot find conda-forge's flat geotiff.h; enable GeoTIFF with
# the first release containing 4d920c5 and add geotiff/libtiff to host.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHDF5_ROOT="${PREFIX}" \
  -DBUILD_TESTING=ON \
  -DNEP_BUILD_DOCUMENTATION=OFF \
  -DNEP_BUILD_EXAMPLES=OFF \
  -DNEP_ENABLE_BENCHMARKS=OFF \
  -DNEP_ENABLE_PARALLEL_TESTS=OFF \
  -DNEP_ENABLE_FORTRAN=ON \
  -DNEP_ENABLE_PDB=ON \
  -DNEP_ENABLE_MMCIF=ON \
  -DNEP_ENABLE_FITS=ON \
  -DNEP_ENABLE_PDS4=ON \
  -DNEP_ENABLE_GEOTIFF=OFF \
  -DNEP_ENABLE_GRIB2=OFF \
  -DNEP_ENABLE_CDF=OFF \
  -DNEP_ENABLE_DICOM=OFF \
  -DNEP_ENABLE_NEXTCDF4=OFF
cmake --build build --parallel "${CPU_COUNT}"
ctest --test-dir build --output-on-failure --no-tests=error --parallel "${CPU_COUNT}"
cmake --install build
