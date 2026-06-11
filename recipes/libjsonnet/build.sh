#!/bin/bash -e
cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTS=OFF \
    -DUSE_SYSTEM_JSON=ON \
    -DBUILD_SHARED_BINARIES=ON \
    "-DCMAKE_CXX_FLAGS=-I${PREFIX}/include/nlohmann"
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
