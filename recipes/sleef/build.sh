#!/usr/bin/env bash

mkdir build
cd build

if [[ "$(uname)" != "Darwin" ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi

cmake \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

cmake --build . --target install
