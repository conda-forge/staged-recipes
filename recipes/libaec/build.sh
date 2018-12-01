#!/bin/bash

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_INCLUDEDIR=include \
    ..
make -j${CPU_COUNT}
ctest -R "check_code_options|check_buffer_sizes|check_long_fs"
make install
