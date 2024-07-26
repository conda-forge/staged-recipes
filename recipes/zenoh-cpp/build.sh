#!/bin/sh

cd ./install
rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja $SRC_DIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=OFF

cmake --build . --config Release
cmake --build . --config Release --target install
