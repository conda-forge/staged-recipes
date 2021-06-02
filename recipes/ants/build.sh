#!/usr/bin/env bash

BUILD_DIR=$SRC_DIR/build
mkdir $BUILD_DIR
cd $BUILD_DIR

cmake $CMAKE_ARGS -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DANTS_SUPERBUILD:BOOL=OFF \
    -DITK_USE_SYSTEM_FFTW:BOOL=ON
    ..

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
