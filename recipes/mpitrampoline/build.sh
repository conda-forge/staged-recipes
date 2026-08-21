#!/bin/bash
cmake -B build -G Ninja \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_APPBUNDLE=NEVER \
    -DCMAKE_FIND_FRAMEWORK=NEVER \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build
cmake --install build
