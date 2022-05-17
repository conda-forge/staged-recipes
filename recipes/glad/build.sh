#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DGLAD_INSTALL:BOOL=ON \
      -DGLAD_REPRODUCIBLE:BOOL=ON \
      -DGLAD_ALL_EXTENSIONS:BOOL=ON \
      ..

cmake --build . --config Release
cmake --build . --config Release --target install
