#!/usr/bin/env bash

set -ex

cmake \
  -B _build \
  -DBUILD_SHARED_LIBS=ON \
  -DMODULES="CC" \
  -DALLOW_CONDA=ON \
  ${CMAKE_ARGS}
cmake --build _build --parallel
cmake --install _build
