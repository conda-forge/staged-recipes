#!/bin/sh

CMAKE_GENERATOR="Unix Makefiles"

cmake -G "$CMAKE_GENERATOR" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release

make
make install
