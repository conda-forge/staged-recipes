#!/bin/bash

./autogen.sh
./configure  --prefix $PREFIX --enable-libunwind

export LD_LIBRARY_PATH=$PREFIX:$LD_LIBRARY_PATH

make
make check
make install
