#!/bin/bash

cd source
chmod +x configure install-sh

./configure --prefix="$PREFIX" \
    --disable-samples \
    --disable-extras \
    --disable-layout \
    --disable-tests \
    --enable-static

make -j$CPU_COUNT
make check
make install

rm -rf $PREFIX/sbin
