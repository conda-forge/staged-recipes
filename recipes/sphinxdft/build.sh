#!/bin/bash

# MKL patch - requires autoconf
mkdir -p src/playground
touch src/playground/Makefile.am
autoreconf -vif
rm -rf src/playground

# Setup
export CXX=$GXX
./configure OBJCXX=${CXX} --disable-debug --with-sxmath --enable-mkl --prefix=${PREFIX} --with-mklpath=${PREFIX} --enable-mklfft
make all -j${CPU_COUNT}
make install 
