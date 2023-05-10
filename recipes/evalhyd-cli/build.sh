#!/bin/bash
set -ex

cmake ${CMAKE_ARGS}                                                           \
      -G "Ninja"                                                              \
      -B build/                                                               \
      -D CMAKE_INSTALL_PREFIX="${PREFIX}"                                     \
      -D CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"  \
      -D CMAKE_INSTALL_LIBDIR=lib                                             \
      -D CMAKE_BUILD_TYPE=Release

cmake --build build/ --parallel ${CPU_COUNT}

cmake --install build/ --prefix ${PREFIX}
