#!/bin/bash

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -G Ninja \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PYTHONDIR=${SP_DIR} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..
ninja install
