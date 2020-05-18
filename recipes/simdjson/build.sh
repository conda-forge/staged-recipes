#!/bin/bash
set -e

pushd singleheader
# shared build
$CXX --std=c++17 -O2 -fPIC -Wall -Wextra simdjson.cpp -shared -o libsimdjson.so
# static build
$CXX --std=c++17 -O2 -Wall -Wextra simdjson.cpp -c -o simdjson.o
$AR -rc libsimdjson.a simdjson.o
popd

# install
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
cp singleheader/simdjson.h $PREFIX/include/simdjson.h
cp singleheader/libsimdjson.so $PREFIX/lib/libsimdjson.so
cp singleheader/libsimdjson.a $PREFIX/lib/libsimdjson.a
