#!/bin/bash

autoconf
./configure --enable-openmp --enable-noisy-make --enable-pic
make -j${CPU_COUNT}
make test

# Do the install by hand (not included in package)
cp -r auto/include/* ${PREFIX}/include
cp -r auto/lib/* ${PREFIX}/lib
