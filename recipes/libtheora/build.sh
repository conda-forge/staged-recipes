#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

./configure --prefix=${PREFIX} --disable-examples --disable-spec
make
make check
make install
