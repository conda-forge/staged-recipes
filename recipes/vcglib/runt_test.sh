#!/bin/bash

set -euxo pipefail

cmake tests \
    ${CMAKE_ARGS} \
    -G Ninja \
    -B tests/build \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release

cmake --build tests/build --parallel
