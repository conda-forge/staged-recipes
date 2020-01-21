#!/usr/bin/env bash

cd source
./prepare
./configure --prefix=$PREFIX
make
make check
make install
