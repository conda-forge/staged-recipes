#!/bin/bash

aclocal
automake --add-missing
autoconf

./configure --prefix=$PREFIX
make
make check TESTS="tests/runtestA1.sh tests/runtestB1.sh tests/runtestB2.sh tests/runtestB3.sh tests/runtestC1.sh tests/runtestC2.sh tests/runtestC3.sh tests/runtestD1.sh tests/runtestD2.sh tests/runtestD3.sh"
make install
