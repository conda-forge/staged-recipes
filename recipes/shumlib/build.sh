#!/usr/bin/env bash
set -euxo pipefail

# CMake options mirror mo-spack-packages' shumlib recipe: OpenMP on (the default
# LFRic builds against), the bitwise NaN/denormal/IEEE probes off, tests off. The
# conda-specific bits are BUILD_SHARED_LIBS=ON (so run_exports means something) and
# CMAKE_INSTALL_LIBDIR=lib (shumlib honours GNUInstallDirs, which would otherwise
# pick lib64 on some hosts; LFRic looks under $SHUMLIB_ROOT/lib).
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_OPENMP=ON \
  -DBUILD_FTHREADS=OFF \
  -DBUILD_TESTS=OFF \
  -DIEEE_ARITHMETIC=OFF \
  -DNAN_BY_BITS=OFF \
  -DDENORMAL_BY_BITS=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
