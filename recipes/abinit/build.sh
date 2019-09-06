#!/bin/bash
autoreconf --install
autoconf
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make -j${CPU_COUNT} installcheck
make -j${CPU_COUNT} install
