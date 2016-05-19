#!/usr/bin/env bash

echo $PREFIX
./configure --prefix=$PREFIX
make
make install
make check
