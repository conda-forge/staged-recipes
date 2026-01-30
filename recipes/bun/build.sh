#!/bin/bash

set -exuo pipefail

# bun needs to be on the PATH for the scripts to work
export PATH="$(pwd)/bun.native:${PATH}"

export CMAKE_AR="$(which ${AR})"
export CMAKE_STRIP="$BUILD_PREFIX/bin/strip"

# Invalid environment variable: CI="azure", please use CI=<ON|OFF>
unset CI

if [[ $target_platform =~ linux.* ]]; then
  export CC_FOR_BUILD=x86_64-conda-linux-gnu-clang
  export CC=x86_64-conda-linux-gnu-clang
  export CFLAGS="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/bun-1.3.7 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix"
  export CMAKE_ARGS="-DCMAKE_AR=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar -DCMAKE_CXX_COMPILER_AR=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar -DCMAKE_C_COMPILER_AR=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar -DCMAKE_RANLIB=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_CXX_COMPILER_RANLIB=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_C_COMPILER_RANLIB=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ranlib -DCMAKE_LINKER=$BUILD_PREFIX/bin/lld -DCMAKE_STRIP=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-strip -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH=$PREFIX;$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_PROGRAM_PATH=$BUILD_PREFIX/bin;$PREFIX/bin"
  export LD="$BUILD_PREFIX/bin/lld"
  rm -f $BUILD_PREFIX/bin/ld
  rm -f $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ld
  ln -s $BUILD_PREFIX/bin/lld $BUILD_PREFIX/bin/ld
  ln -s $BUILD_PREFIX/bin/lld $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ld

  env
  bun ./scripts/build.mjs -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_DSYMUTIL="$(which arm64-apple-darwin20.0.0-dsymutil)" -B build/release
else
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  bun ./scripts/build.mjs -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_DSYMUTIL="$(which arm64-apple-darwin20.0.0-dsymutil)" -B build/release
fi



mkdir -p $PREFIX/bin
cp build/release/bun $PREFIX/bin/bun
