#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j$CPU_COUNT
make install
