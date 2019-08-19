#!/bin/bash
./configure OBJCXX=${CXX} --disable-debug --with-sxmath --enable-mkl --prefix=${PREFIX} --with-mklpath=${PREFIX}
make all
make install 
