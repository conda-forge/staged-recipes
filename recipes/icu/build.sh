#!/bin/bash

cd source
chmod +x configure install-sh

if [ "$(uname)" == "Linux" ]; then
    ./configure --prefix="$PREFIX"
fi

if [ "$(uname)" == "Darwin" ]; then
    ./configure --prefix="$PREFIX" \
        --disable-samples \
        --disable-tests \
        --enable-static \
        --with-library-bits=64
fi

make
make install
