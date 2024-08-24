#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBOOST_STATIC=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DFETCH_COLMAP=OFF \
      -DFETCH_POSELIB=OFF \
      ..

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
