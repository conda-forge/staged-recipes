#!/bin/bash -e
cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build --preset default \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF \
    -DENABLE_CLANG_TIDY=OFF
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
