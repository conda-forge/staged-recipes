#!/bin/bash

set -ex


if [ "$target_platform" = "osx-arm64" ]; then
  export CMAKE_OSX_ARCHITECTURES="arm64"
fi

rm -rf build && mkdir build && cd build
cmake ${CMAKE_ARGS} -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  ..

ninja
ninja install

