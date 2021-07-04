#!/bin/bash

./autogen.sh
CFLAGS="-Wno-error $CFLAGS" ./configure --prefix=$PREFIX
make -j$CPU_COUNT
make check
make install
