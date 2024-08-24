#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

ninja install
