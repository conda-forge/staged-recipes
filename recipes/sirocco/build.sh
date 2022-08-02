#!/bin/bash

autoreconf --install
./configure --prefix=$PREFIX --libdir=$PREFIX/lib
make -j${CPU_COUNT}
make install
