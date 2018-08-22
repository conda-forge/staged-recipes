#!/bin/bash

set -ex

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
fi

# ln -s $BUILD_PREFIX/bin/bison++ $BUILD_PREFIX/bin/yacc

./configure \
    --prefix=$PREFIX \
    flex++-2.3.8
 
make firstflex
make test
make install
