#!/bin/bash

set -ex

# remove test failing in non interactive shell
rm ext/standard/tests/file/lstat_stat_variation10.phpt

./configure --prefix=$PREFIX --with-iconv=$PREFIX --with-openssl=$PREFIX --with-libxml-dir=$PREFIX
make -j${CPU_COUNT}

export NO_INTERACTION=1
script -ec "make test"

make install
