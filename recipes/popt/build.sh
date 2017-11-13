#!/bin/sh

set -e -o pipefail

./configure --prefix=$PREFIX
make
make check
make install
