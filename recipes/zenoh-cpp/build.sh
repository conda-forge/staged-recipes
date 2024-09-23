#!/bin/sh

cd ./install
rm -rf build
mkdir build
cd build

# tests are disabled as of 0.11.0 they depend on zenohc's static library
# switch them on on 1.0.0 as they can be compiled against zenohc's shared library
cmake ${CMAKE_ARGS} -GNinja $SRC_DIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=OFF

cmake --build . --config Release
cmake --build . --config Release --target install
