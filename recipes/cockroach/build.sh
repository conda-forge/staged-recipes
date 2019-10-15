#!/bin/bash

if [[ "$target_platform" == "osx-64" ]]; then
  export CC=clang
  export CXX=clang++
  export CMAKE_CC=clang
  export CMAKE_CXX=clang++
fi

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export CXXFLAGS="-std=c++17 -std=gnu++17"


pushd src/github.com/cockroachdb/${PKG_NAME}
make build
make install

