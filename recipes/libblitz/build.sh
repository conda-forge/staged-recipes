#!/bin/bash

autoreconf -fi
./configure \
  --prefix="${PREFIX}" \
  --enable-static \
  --enable-shared \
  --enable-optimize \
  --enable-64bit \
  --enable-threadsafe \
  CPPFLAGS="-I${PREFIX}/include -pthread" \
  LDFLAGS="-L${PREFIX}/lib"
make
make install
