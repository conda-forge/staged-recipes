#!/usr/bin/env bash
set -e
set -x

./configure --prefix=$PREFIX
make
# make check is not available
make install
