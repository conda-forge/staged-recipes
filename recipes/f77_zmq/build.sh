#!/bin/bash

./configure --prefix=${PREFIX} --libdir=${PREFIX}/lib --includedir=${PREFIX}/include

make
FAILURE=0
make check || FAILURE=$?
if [[ $FAILURE -ne 0 ]] ; then
  cat ./test-suite.log
  exit $FAILURE
fi
make install
