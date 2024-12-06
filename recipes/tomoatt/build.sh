#!/bin/bash

set -e

mkdir build && cd build

uname -p
uname -m
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX ..
make -j$CPU_COUNT
make install

