#!/bin/bash

mkdir build && cd build

cmake -G "$CMAKE_GENERATOR" \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX="$PREFIX" \
      -D CARES_STATIC=ON \
      -D CARES_INSTALL=ON \
      ${SRC_DIR}

cmake --build . --config Release --target install
