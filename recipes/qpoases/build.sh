#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DQPOASES_AVOID_LA_NAMING_CONFLICTS:BOOL=ON \
      -DBUILD_TESTING:BOOL=ON ..

cmake --build . --config Release
cmake --build . --config Release --target install
ctest --output-on-failure -C Release