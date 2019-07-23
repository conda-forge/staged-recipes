#!/usr/bin/env bash

export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export CFLAGS="-O3 ${CFLAGS}"
export CXXFLAGS="-O3 ${CXXFLAGS}"

./configure --prefix="${PREFIX}"
( make > make.out ) || ( cat make.out && exit 1 )
make check || ( cat test/test-suite.log && exit 1 )
make install
