#!/usr/bin/env bash

./configure \
    --prefix="${PREFIX}"  \
    --enable-libxml2-backend

make
make install

pushd tools
make
make install
popd

make check
