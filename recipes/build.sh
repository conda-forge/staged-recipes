#!/usr/bin/env bash

set -e

UNAME="$(uname)"
export CFLAGS="-O3"
export CXXFLAGS="-O3"

if [ "${UNAME}" == "Darwin" ]; then
    # for Mac OSX
    export CC=clang
    export CXX=clang++
    export MACOSX_VERSION_MIN="10.7"
    export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LDFLAGS="${LDFLAGS} -stdlib=libc++ -lc++"
    export LINKFLAGS="${LDFLAGS}"
fi

./configure --prefix="${PREFIX}" || { cat config.log; exit 1; }
make
make install
