#!/bin/bash

set -ex

./configure --prefix=$PREFIX --with-libgmp

make -j$CPU_COUNT

make check

make install
