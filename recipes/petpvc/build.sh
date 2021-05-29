#!/usr/bin/env bash

BUILD_DIR=$SRC_DIR/build
mkdir $BUILD_DIR
cd $BUILD_DIR

cmake $CMAKE_ARGS -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    ..

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .

rm -rf $PREFIX/parc
