#!/bin/bash

./configure \
￼    --prefix=${PREFIX} \
￼    --libdir=${PREFIX}/lib \
￼    --includedir=${PREFIX}/include

make
FAILURE=0
make check || FAILURE=1
if [[ $FAILURE -eq 1 ]] ; then
  cat ./test-suite.log
fi
make install
