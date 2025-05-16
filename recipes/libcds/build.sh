#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      ${SRC_DIR}

cmake --build . --config Release
cmake --build . --config Release --target install

ctest
