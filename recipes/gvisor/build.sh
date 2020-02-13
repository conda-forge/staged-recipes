#!/usr/bin/env bash

## Legacy toolchain flags
#if [[ ${c_compiler} =~ .*toolchain.* ]]; then
#    if [ $(uname) == "Darwin" ]; then
#        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
#        export CC=clang
#        export CXX=clang++
#    else
#        export LDFLAGS="$LDFLAGS -Wl,--disable-new-dtags"
#    fi
#fi
#if [[ ${target_platform} != osx-64 ]]; then
#    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,$PREFIX/lib"
#fi

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib/cyclus:${PREFIX}/lib:${LD_LIBRARY_PATH}"

#pushd {{ pkg_src }}

bazel build runsc