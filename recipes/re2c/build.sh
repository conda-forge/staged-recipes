#!/bin/bash
set -e
export CXXFLAGS="-std=c++11 $CXXFLAGS"
./autogen.sh
./configure --prefix=${PREFIX}
make
make check || (cat test-suite.log && exit 1)
make install
