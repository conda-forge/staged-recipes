#!/bin/bash

set -exuo pipefail

# bun needs to be on the PATH for the scripts to work
export PATH="$(pwd)/bun.native:${PATH}"

export CMAKE_AR="$(which ${AR})"
if [[ "${target_platform}" == osx-* ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_DSYMUTIL=$(which ${HOST}-dsymutil)"
  export CMAKE_LLD="$(which lld)"
  export CMAKE_STRIP="$BUILD_PREFIX/bin/llvm-strip"
else
  export CMAKE_LLD="$(which ld.lld)"
  export CMAKE_STRIP="$(which ${STRIP})"
fi

export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_AR=${CMAKE_AR} -DCMAKE_STRIP=${CMAKE_STRIP} -DUSE_STATIC_SQLITE=OFF -DUSE_STATIC_LIBATOMIC=OFF"

# Invalid environment variable: CI="azure", please use CI=<ON|OFF>
unset CI

bun ./scripts/build.mjs -GNinja -DCMAKE_BUILD_TYPE=Release ${CMAKE_ARGS} -B build/release

mkdir -p $PREFIX/bin
cp build/release/bun $PREFIX/bin/bun
