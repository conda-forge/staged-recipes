#!/bin/bash

git submodule init
git submodule update

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBLAS_LIBRARIES="$PREFIX/lib/libopenblas${SHLIB_EXT}" \
    -DLAPACK_LIBRARIES="$PREFIX/lib/libopenblas${SHLIB_EXT}" \
    ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release --prefix "$PREFIX"
