#!/bin/bash
cat sxaccelerate/src/system/m4/sxnumlibs.m4 
ls -al ${PREFIX}/lib/libmkl_*
./configure OBJCXX=${CXX} --disable-debug --with-sxmath --enable-mkl --prefix=${PREFIX} --with-mklpath=${PREFIX}
make all
make install 
