#!/bin/bash

./configure \
￼    --prefix=${PREFIX} \
￼    --libdir=${PREFIX}/lib \
￼    --includedir=${PREFIX}/include

make
make check
cat ./test-suite.log
make install
