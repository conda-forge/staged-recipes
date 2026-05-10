#!/bin/bash

set -exo pipefail

cmake $SRC_DIR \
    ${CMAKE_ARGS} \
    -G Ninja \
    -B build \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIB_SUFFIX="" \
    -DMAGNUM_WITH_PYTHON=ON \
    -DMAGNUM_BUILD_TESTS=OFF

cmake --build build --parallel
cmake --build build --target install

cd build/src/python
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
