#!/usr/bin/env bash
set -euxo pipefail

# Header/template library: the build step mostly stages generated templates, and
# install copies them plus the CMake package config into $PREFIX/GFTL-<x.y>/.
# BUILD_TESTING=OFF because gFTL's own tests want pFUnit (its CMakeLists does a
# `find_package(PFUNIT 4.1 QUIET)`), which is not present at build time.
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_TESTING=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
