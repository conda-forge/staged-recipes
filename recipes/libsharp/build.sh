#!/bin/bash

set -e

autoconf
./configure --enable-openmp --enable-noisy-make --enable-pic
make -j${CPU_COUNT}
make test

# Do the install by hand (not included in package)
cp -R auto/include/* ${PREFIX}/include
cp -R auto/lib/* ${PREFIX}/lib
