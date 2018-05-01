#!/bin/bash

./autogen.sh
./configure --prefix $PREFIX/usr

make

# test
make check

make install
