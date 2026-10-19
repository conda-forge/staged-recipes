#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}/projects/amdsmi"
mkdir -p build && cd build

cmake -G Ninja ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_CLI=ON \
    -DBUILD_WRAPPER=OFF \
    -DBUILD_RUST_WRAPPER=OFF \
    -DENABLE_ESMI_LIB=ON \
    -DENABLE_LDCONFIG=OFF \
    "${SRC_DIR}/projects/amdsmi"

cmake --build . --target amd_smi python_package amdsmi_cli
cmake --build . --target install
