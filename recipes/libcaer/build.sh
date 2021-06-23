#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DUDEV_INSTALL=False \
      -DENABLE_OPENCV=1

cmake --build . --config Release
cmake --build . --config Release --target install
