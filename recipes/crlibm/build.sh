#!/usr/bin/env bash

cd src
./prepare
./configure --prefix=$PREFIX
make
make check
make install
