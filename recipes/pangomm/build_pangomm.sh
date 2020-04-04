#!/bin/bash

./configure --prefix=${PREFIX} \
    --enable-shared \
    --disable-static \
|| { cat config.log; exit 1; }

make -j${CPU_COUNT}
make check
make install
