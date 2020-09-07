#!/usr/bin/env bash

mkdir build && cd build

cmake -DDD4HEP_USE_GEANT4=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ../source

cmake --build . --target install -j${CPU_COUNT}
