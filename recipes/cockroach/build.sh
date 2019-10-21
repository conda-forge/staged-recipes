#!/bin/bash

CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ${CMAKE_PLATFORM_FLAGS[@]} \
  ${SRC_DIR}

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

