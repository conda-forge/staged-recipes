#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"

mkdir build && cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX $SRC_DIR
make -j$CPU_COUNT && make test && make install
