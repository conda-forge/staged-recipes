#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBOOST_STATIC=OFF \
      -DCUDA_ENABLED=OFF \
      -DBUILD_SHARED_LIBS=ON \
      ..

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
