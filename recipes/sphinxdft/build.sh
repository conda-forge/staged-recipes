#!/bin/bash
mkdir -p src/playground
touch src/playground/Makefile.am
autoreconf -vif
rm -rf src/playground
./configure OBJCXX=${CXX} --disable-debug --with-sxmath --enable-mkl --prefix=${PREFIX} --with-mklpath=${PREFIX} --enable-mklfft
make all
make install 
