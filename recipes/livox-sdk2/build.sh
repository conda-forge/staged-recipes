#!/bin/sh

rm -rf build

cmake -B build ${CMAKE_ARGS} -GNinja $SRC_DIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-w"

cmake --build build --config Release
cmake --build build --config Release --target install
