#!/usr/bin/env bash

autoreconf -i 
./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

