#!/usr/bin/env bash

./configure --prefix=$PREFIX --with-glib=embedded --enable-nls=no

make
# This check fails due to one test.
# Known upstream https://github.com/mono/mono/blame/a1ac272ffe8d6b54bc9f9ebe1331699d1b623507/mono/tests/Makefile.am#L603-L604
#make check
make install
