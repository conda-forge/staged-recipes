#!/usr/bin/env bash
set -e

export CFLAGS="-std=c++11 ${CFLAGS}"
export CXXFLAGS="-std=c++11 ${CXXFLAGS}"

./autogen.sh
./configure --prefix=${PREFIX} --with-boost=${BUILD_PREFIX} --with-boost-libdir=${BUILD_PREFIX}/lib
make
make install
