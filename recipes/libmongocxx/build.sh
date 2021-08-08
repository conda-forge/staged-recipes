#!/bin/sh

[[ -d build ]] || mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DBSONCXX_POLY_USE_BOOST=1 \
      -DENABLE_STATIC=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SHARED_LIBS=ON

cmake --build . --config Release
cmake --build . --config Release --target install
