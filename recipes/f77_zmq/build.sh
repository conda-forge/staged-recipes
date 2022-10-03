#!/bin/bash

./configure --prefix=${PREFIX} --libdir=${PREFIX}/lib --includedir=${PREFIX}/include --disable-static

make
FAILURE=0

# Check if we are on Linux
if [[ -f ${PREFIX}/lib/libzmq.so ]] ; then
  make check || FAILURE=$?
  if [[ $FAILURE -ne 0 ]] ; then
    cat ./test-suite.log
    exit $FAILURE
  fi
fi
make install
