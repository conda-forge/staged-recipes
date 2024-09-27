#!/bin/bash

if [[ "$target_platform" == "osx-64" ||  "$target_platform" == "osx-arm64" ]]; then
  if [[ $(clang --version | grep -oE "[0-9]+" | head -1) -le 1300 ]]; then
    export CC=$(which clang)
    export CXX=$(which clang++)
  fi
fi

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j${CPU_COUNT}
make install
