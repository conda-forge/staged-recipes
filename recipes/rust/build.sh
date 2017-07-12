#!/bin/bash -e

./configure --disable-codegen-tests --prefix=$PREFIX --llvm-root=$PREFIX
make
make install

cd cargo
./configure --prefix=$PREFIX
make
make install
