#!/usr/bin/env bash

set -ex
cp $RECIPE_DIR/CMakeLists.txt $RECIPE_DIR/hptt-config.cmake.in .
cmake \
  -B _build \
  -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DHPTT_VERSION=${PKG_VERSION} \
  ${CMAKE_ARGS}
cmake --build _build
cmake --install _build
