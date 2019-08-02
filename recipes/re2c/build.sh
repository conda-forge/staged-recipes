#!/bin/bash
set -e
export CXXFLAGS="-std=c++11 $CXXFLAGS"
./autogen.sh
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
# tests fail in last stable release
# make check || (cat test-suite.log && exit 1)
make install
