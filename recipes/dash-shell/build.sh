#!/bin/bash

set -xe

./autogen.sh
./configure --prefix $PREFIX --mandir=$PREFIX/man --with-libedit --enable-glob --enable-fnmatch
make  -j$CPU_COUNT
#make check doesn't do anything... :(
make  install
