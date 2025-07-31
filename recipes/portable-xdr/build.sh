#!/bin/bash

# Configure
cmake ${CMAKE_ARGS} \
    -G Ninja \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=${PREFIX} \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -S ${SRC_DIR} \
    -B build

# Build & Install
cmake --build build --target install
