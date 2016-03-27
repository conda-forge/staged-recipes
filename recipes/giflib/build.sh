#!/bin/bash

./configure --prefix=${PREFIX}
make
if [[ $(uname) == Linux ]]; then
    make check
fi
make install
