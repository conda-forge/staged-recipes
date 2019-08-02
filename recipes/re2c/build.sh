#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make check
make install
