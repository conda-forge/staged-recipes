#!/bin/bash

./configure --prefix="${PREFIX}"
    # CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"  \
    # LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

make
make install
