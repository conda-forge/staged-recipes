#!/usr/bin/env bash
set -euxo pipefail

# CMake options: OpenMP on (upstream's default), the bitwise NaN/denormal/IEEE
# probes off, tests off.
#
# BUILD_OPENMP=ON is upstream's default, but on its own the CMake build takes it
# only as far as `find_package(OpenMP 3.0 REQUIRED)`: nothing links the
# resulting OpenMP:: targets, so -fopenmp never reaches a compile line and the
# OpenMP regions are compiled out. patches/0002-link-openmp.patch links them, so
# this flag now does what it says and the library really is threaded -- matching
# what upstream's Makefile build produces by default (SHUM_OPENMP ?= true).
# That is why the OpenMP runtime appears in the host requirements.
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
