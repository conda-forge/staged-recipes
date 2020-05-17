#!/bin/bash
set -e

# shared build
pushd singleheader
$CXX -fPIC -Wall -Werror -Wextra -pedantic simdjson.cpp -shared -o libsimdjson.so
$CXX -Wall -Werror -Wextra -pedantic simdjson.cpp -o simdjson.o
$AR -rc libsimdjson.a simdjson.o
popd

# install
mkdir -p $PREFIX/include
cp singleheader/simdjson.h $PREFIX/include/simdjson.h
cp singleheader/libsimdjson.so $PREFIX/lib/libsimdjson.so
cp singleheader/libsimdjson.a $PREFIX/lib/libsimdjson.a
