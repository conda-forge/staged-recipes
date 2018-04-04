#!/bin/bash

set -ex

if [ $(uname) == Darwin ]; then
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    CC=clang
    CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
else
    export CXXFLAGS="$CXXFLAGS -std=c++11"
fi

cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release

make -j $CPU_COUNT
make install
