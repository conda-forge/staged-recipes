#!/bin/bash

autoreconf --install
./configure --prefix=$PREFIX/local --libdir=$PREFIX/local/lib
make -j${CPU_COUNT}
make install
