#!/usr/bin/env bash


mkdir -p build && cd build

cmake ${CMAKE_ARGS} -G Ninja \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      ${SRC_DIR}

ninja
ninja install
