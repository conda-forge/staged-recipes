#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \
    -DCMAKE_BUILD_TYPE=Release \
    ../libgta
make -j $CPU_COUNT
make install
