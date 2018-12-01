#!/bin/bash

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_INCLUDEDIR=include \
    ..
make -j${CPU_COUNT}
ctest -R "check_szcomp|sampledata.sh"
make install
