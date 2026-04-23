#!/bin/bash
set -exo pipefail

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DOIDN_DEVICE_CPU=ON \
    -DOIDN_FILTER_RT=ON \
    -DOIDN_FILTER_RTLIGHTMAP=ON \
    -DOIDN_APPS=OFF \
    -DOIDN_INSTALL_DEPENDENCIES=OFF
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
