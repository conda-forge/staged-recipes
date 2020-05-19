#!/bin/bash
set -e

pushd singleheader
# simdjson requires c++17
export CXXFLAGS="$CXXFLAGS --std=c++17 -O2 -fPIC -Wall -Wextra"
$CXX $CXXFLAGS simdjson.cpp -shared -o libsimdjson.so
popd

# install
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
cp singleheader/simdjson.h $PREFIX/include/simdjson.h
cp singleheader/libsimdjson.so $PREFIX/lib/libsimdjson.so
