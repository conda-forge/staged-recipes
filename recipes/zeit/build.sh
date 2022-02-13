#!/bin/bash

mkdir build

cmake -B 'build' -S . \
    -DCMAKE_BUILD_TYPE='None' \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_TESTS=ON \
    -Wno-dev

make -C 'build'

./build/tests/tests

make PREFIX=$PREFIX -C 'build' install

