#!/bin/bash

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
./configure --prefix=${PREFIX} --enable-sse
make
make install
