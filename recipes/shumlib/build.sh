#!/usr/bin/env bash
set -euxo pipefail

# CMake options: OpenMP on (upstream's default), the bitwise NaN/denormal/IEEE
# probes off, tests off.
#
# BUILD_OPENMP=ON is worth less than it looks in the CMake build: it only makes
# upstream run `find_package(OpenMP 3.0 REQUIRED)`, and nothing links the
# resulting OpenMP:: targets or puts -fopenmp on a compile line, so _OPENMP is
# never defined and libshum acquires no OpenMP runtime dependency. (Upstream's
# older Makefile build does apply the flags for SHUM_OPENMP=true.) It stays ON
# to match upstream's default and to keep the flag correct if the CMake build
# is fixed to link OpenMP; if that happens, the OpenMP runtime will need to be
# added to the host requirements.
#
# The conda-specific bits are BUILD_SHARED_LIBS=ON (so run_exports means something)
# and CMAKE_INSTALL_LIBDIR=lib (shumlib honours GNUInstallDirs, which would
# otherwise pick lib64 on some hosts, while consumers look under
# $SHUMLIB_ROOT/lib).
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
