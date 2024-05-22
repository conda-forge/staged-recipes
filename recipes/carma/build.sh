#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
    -DCMAKE_INSTALL_DATAROOTDIR=${PREFIX}/share \
    -DCARMA_INSTALL_LIB:BOOL=ON \
    ..

cmake --build . --config Release --target install