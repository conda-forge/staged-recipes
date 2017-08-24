#!/bin/bash

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export CPPFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

./configure --prefix=$PREFIX
make -j $CPU_COUNT
make check
make install
