#!/usr/bin/env bash
set -x
set -e

./configure --prefix=$PREFIX
make
make install
make check
