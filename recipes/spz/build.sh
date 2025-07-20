#!/usr/bin/env bash


mkdir -p build && cd build

cmake ${CMAKE_ARGS} -G Ninja \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DBUILD_SHARED_LIBS=ON \
      ${SRC_DIR}

ninja
ninja install
