#!/bin/bash

cd source
chmod +x configure install-sh

./configure --prefix="$PREFIX" \
    --disable-samples \
    --disable-tests \
    --enable-static

make
make check
make install
