#!/bin/bash

./autogen.sh
./configure  --prefix $PREFIX --enable-libunwind

make
make check
make install
