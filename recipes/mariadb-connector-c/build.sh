#!/bin/bash

set -e

mkdir build

cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    ${SRC_DIR}

cmake --build . --config RelWithDebInfo --parallel ${CPU_COUNT} --target install