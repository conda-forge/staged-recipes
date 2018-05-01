#!/bin/bash

./autogen.sh
./configure CC=$PREFIX/bin/gcc --prefix $PREFIX --exec-prefix=$PREFIX --enable-libunwind

make

make install
