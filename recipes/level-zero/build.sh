#! /usr/bin/bash

mkdir build
mkdir install

cmake -DCMAKE_INSTALL_PREFIX="${SRC_DIR}/install" \
    -S ${SRC_DIR}/level-zero \
    -B ${SRC_DIR}/build \
    -Wno-dev
cmake --build ${SRC_DIR}/build --config Release -- -j${CPU_COUNT}
cmake --build ${SRC_DIR}/build --config Release --target install
