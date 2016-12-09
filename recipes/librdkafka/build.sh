#!/bin/bash

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

./configure --prefix=$PREFIX
make -j $CPU_COUNT
make check
make install
