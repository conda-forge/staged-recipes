#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake -DDISABLE_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    ..

make
make install
