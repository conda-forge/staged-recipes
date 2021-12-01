#!/bin/bash

set -ex

autoreconf -fiv

./configure --prefix=$PREFIX
make

make check

make install
