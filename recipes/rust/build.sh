#!/bin/bash -e

./configure --prefix=$PREFIX --llvm-root=$PREFIX
make
make install
