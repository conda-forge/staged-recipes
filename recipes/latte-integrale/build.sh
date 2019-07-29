#!/bin/bash

# We can not use C++17 due to https://stackoverflow.com/questions/47284705/c1z-dynamic-exception-specification-error
export CXXFLAGS="$CXXFLAGS -std=c++14"

./configure --prefix=$PREFIX --with-ntl=$PREFIX --with-cddlib=$PREFIX || (cat config.log; false)
make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install
