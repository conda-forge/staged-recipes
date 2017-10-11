#!/bin/sh

set -e -o pipefail

./configure --prefix=$PREFIX --without-included-zlib --without-included-popt
make
make check
make install
