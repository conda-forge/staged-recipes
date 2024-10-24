#!/bin/bash

set -x

autoreconf -vfi

export CFLAGS="${CFLAGS} -O3 -g -march=native"

./configure --prefix=${PREFIX} \
            --with-pic

make -j ${CPU_COUNT} all
make install
