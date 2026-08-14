#!/bin/bash

set -ex

cmake ${CMAKE_ARGS} \
  -S "$SRC_DIR/client/src/python" \
  -B build-python \
  -GNinja \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_REPO-COMMON="$SRC_DIR/common" \
  -DPython_EXECUTABLE="$PYTHON" \
  -DTRITON_ENABLE_EXAMPLES=OFF \
  -DTRITON_ENABLE_GPU=OFF \
  -DTRITON_ENABLE_PYTHON_GRPC=ON \
  -DTRITON_ENABLE_PYTHON_HTTP=ON \
  -DTRITON_ENABLE_TESTS=OFF \
  -DTRITON_VERSION="$PKG_VERSION"
cmake --build build-python --target generic-client-wheel --parallel "$CPU_COUNT"
"$PYTHON" -m pip install build-python/library/generic/tritonclient-*.whl --no-deps --no-build-isolation -vv
