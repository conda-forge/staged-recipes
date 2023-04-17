#!/bin/bash

cmake ${CMAKE_ARGS}                     \
      -B build/                         \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CMAKE_CXX_STANDARD=17          \
      -D CMAKE_INSTALL_LIBDIR=lib       \
      -D CMAKE_BUILD_TYPE=Release

cmake --build build/ --parallel ${CPU_COUNT}

cmake --install build/ --prefix ${PREFIX}
