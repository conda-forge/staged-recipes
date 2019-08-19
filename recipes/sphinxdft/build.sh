#!/bin/bash
cat sxaccelerate/src/system/m4/sxnumlibs.m4 
ls -al ${PREFIX}/lib/libmkl_*
if test -f ${PREFIX}/lib/libmkl_sequential.so; then
  echo "file exists" ${PREFIX}/lib/libmkl_sequential.so
else
  echo "file does not exists" ${PREFIX}/lib/libmkl_sequential.so
fi
./configure OBJCXX=${CXX} --disable-debug --with-sxmath --enable-mkl --prefix=${PREFIX} --with-mklpath=${PREFIX}
make all
make install 
