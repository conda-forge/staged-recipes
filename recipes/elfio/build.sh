#!/bin/bash

set -ex

autoreconf -fiv

./configure --prefix=$PREFIX
make

make check || { cat test-suite.log; exit 1; }

make install
