#!/bin/bash

./configure --prefix=${PREFIX} --libdir=${PREFIX}/lib --includedir=${PREFIX}/include

make
FAILURE=0
export LD_LIBRARY_PATH=$LD_LIBRRAY_PATH:${PREFIX}/lib
export DYLD_LIBRARY_PATH=$DYLD_LIBRRAY_PATH:${PREFIX}/lib
make check || FAILURE=$?
if [[ $FAILURE -ne 0 ]] ; then
  cat ./test-suite.log
  exit $FAILURE
fi
make install
