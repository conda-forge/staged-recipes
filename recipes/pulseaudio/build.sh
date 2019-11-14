#!/usr/bin/env bash

NOCONFIGURE=1 ./bootstrap.sh
./configure --prefix=${PREFIX}
make
make check
make install
