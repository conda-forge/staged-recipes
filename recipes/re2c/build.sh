#!/bin/bash
set -e
./autogen.sh
./configure --prefix=${PREFIX}
make
make check || (cat test-suite.log && exit 1)
make install
