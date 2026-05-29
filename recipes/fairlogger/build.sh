#!/bin/bash -e
cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
    -DPROJECT_VERSION=$PKG_VERSION \
    -DCMAKE_CXX_STANDARD=20 \
    -DDISABLE_COLOR=ON \
    -DUSE_EXTERNAL_FMT=ON \
    -DCMAKE_INSTALL_LIBDIR=lib
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
