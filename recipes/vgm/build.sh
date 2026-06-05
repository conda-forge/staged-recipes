#!/bin/bash -e
cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_CXX_STANDARD=20 \
    -DWITH_EXAMPLES=OFF \
    -DWITH_TEST=OFF
cmake --build build --parallel ${CPU_COUNT} --target install
