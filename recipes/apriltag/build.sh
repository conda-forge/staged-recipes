#!/bin/bash
set -ex

cmake -G Ninja -B build \
    ${CMAKE_ARGS} \
    -D BUILD_SHARED_LIBS=ON \
    -D PYTHON_EXECUTABLE=${PYTHON} \
    -D BUILD_PYTHON_WRAPPER=ON \
    -D BUILD_TESTING=ON
cmake --build build --target install

ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/
