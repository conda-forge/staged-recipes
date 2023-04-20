#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build \
    -DVERSION_MAJOR=2 \
    -DVERSION_MINOR=1 \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}
cmake --build build
cmake --install build

make test LIBTOOL=${BUILD_PREFIX}/bin/libtool
