#!/usr/bin/env bash

set -ex

cmake \
  -B _build \
  -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DPython_EXECUTABLE=$PYTHON \
  -DNWX_MODULE_DIRECTORY=$SP_DIR \
  ${CMAKE_ARGS}
cmake --build _build
cmake --install _build
