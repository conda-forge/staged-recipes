#!/usr/bin/env bash
set -euo pipefail

# Portable baseline target: let conda-forge compiler flags and runtime-dispatched
# libblas/liblapack select SIMD levels without requiring AVX2 on legacy CPUs.
cmake -S solver -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBLA_VENDOR=Generic \
  -DSMF_USE_MKL=OFF \
  -DSMF_USE_SUITESPARSE_AMD=ON \
  -DSMF_USE_METIS=ON \
  -DSMF_VENDORED_METIS=ON \
  -DSMF_BUILD_C_API=ON \
  -DSMF_BUILD_MA97_PLUGIN=ON \
  -DSMF_INSTALL_STATIC_LIBS=OFF \
  -DSMF_BUILD_TESTS=OFF \
  -DSMF_BUILD_BENCHMARKS=OFF \
  -DSMF_MARCH=none

cmake --build build -j "${CPU_COUNT}"
cmake --install build
