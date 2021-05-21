#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -DCMAKE_PREFIX_PATH:STRING=${PREFIX} \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DANTS_SUPERBUILD:BOOL=OFF \
    -DUSE_SYSTEM_ITK:BOOL=ON \
    ${SRC_DIR}

cmake --build . --config RelWithDebInfo --parallel ${CPU_COUNT} --target install
