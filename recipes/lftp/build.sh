#!/bin/bash

export CXXFLAGS="-I${PREFIX}/include $CXXFLAGS"

./configure --prefix=${PREFIX} \
    --with-readline=${PREFIX} \
    --with-readline-inc=${PREFIX}/include \
    --with-zlib=${PREFIX} \
    --with-expat=${PREFIX} \
    --with-openssl=${PREFIX} \
    --enable-packager-mode

make
make install
