#!/usr/bin/env bash
./autogen.sh

export CXXFLAGS="-I${PREFIX}/include -I${PREFIX}/include/libxml2"
export LDFLAGS="-L${PREFIX}/lib"

./configure \
  --prefix=${PREFIX} \
  --sbindir=${PREFIX}/bin \
  --with-openssl

make

make install
