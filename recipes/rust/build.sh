#!/bin/bash -e

./configure --prefix=$PREFIX --llvm-root=$PREFIX/lib/
make
make install
