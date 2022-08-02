#!/bin/bash

autoreconf --install
./configure --prefix=$PREFIX --libdir=$PREFIX/lib --disable-static
make -j${CPU_COUNT}
make install
make check
