#! /usr/bin/env bash

if [ "`uname`" != "Darwin" ]; then
  export CC=${PREFIX}/bin/gcc
  export CXX=${PREFIX}/bin/g++
fi

./configure --prefix=${PREFIX} || exit 1
make install -j ${CPU_COUNT} || exit 1
