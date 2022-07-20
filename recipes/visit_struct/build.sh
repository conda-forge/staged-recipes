#!/bin/sh

cp $RECIPE_DIR/CMakeLists.txt $SRC_DIR

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      ..

cmake --build . --config Release
cmake --build . --config Release --target install
