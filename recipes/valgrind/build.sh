#!/bin/sh

set -e -o pipefail

./configure --prefix=${PREFIX} --disable-dependency-tracking --enable-only64bit

make
make install
