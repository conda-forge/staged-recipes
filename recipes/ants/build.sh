#!/usr/bin/env bash

mkdir build
cd build

cmake $CMAKE_ARGS -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_CXX_STANDARD:STRING=11 \
    -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=YES \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DANTS_SNAPSHOT_VERSION:STRING="2.3.5" \
    -DANTS_SUPERBUILD:BOOL=OFF \
    -DITK_USE_SYSTEM_FFTW:BOOL=ON \
    ..

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
