#!/bin/bash

if [ `uname` == Darwin ]; then
    if [ $ARCH == 64 ]; then
        ./Configure darwin64-x86_64-cc shared enable-ssl2 --prefix=$PREFIX
    else
        ./Configure darwin-i386-cc shared enable-ssl2 --prefix=$PREFIX
    fi
else
    ./config shared enable-ssl2 --prefix=$PREFIX
fi

make
make test
make install
