#!/usr/bin/env bash

BUILD_DIR=$SRC_DIR/build
mkdir $BUILD_DIR
cd $BUILD_DIR

cmake $CMAKE_ARGS -G Ninja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF \
    -DANTS_SUPERBUILD:BOOL=OFF \
    ..

cmake --build .

cmake --install .
