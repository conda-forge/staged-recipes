#!/bin/bash

cd source
chmod +x configure install-sh

./configure --prefix="$PREFIX" \
    --disable-samples \
    --disable-extras \
    --disable-icuio \
    --disable-layout \
    --enable-static

make
make check
make install
