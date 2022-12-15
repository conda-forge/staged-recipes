#!/bin/bash

cmake ${CMAKE_ARGS}                     \
      -B build/                         \
      -D EVALHYD_BUILD_TEST=OFF         \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CMAKE_INSTALL_LIBDIR=lib       \
      -D CMAKE_BUILD_TYPE=Release

cmake --build build/ --parallel ${CPU_COUNT}

cmake --install build/ --prefix ${PREFIX}
