#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      ${SRC_DIR}

cmake --build . -j 8 --config Release --target install
