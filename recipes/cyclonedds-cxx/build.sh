#!/bin/bash
set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DBUILD_TESTING=OFF \
      -DBUILD_EXAMPLES=OFF \
      ..

cmake --build . --parallel ${CPU_COUNT}
cmake --install .
