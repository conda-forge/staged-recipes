#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON

cmake --build . --config Release
cmake --build . --config Release --target install
# Some tests disabled due to https://github.com/robotology/ycm/issues/382
ctest --output-on-failure -C Release -E "YCMBootstrap-not-use-system|YCMBootstrap-disable-find|RunCMake.IncludeUrl"
