#!/usr/bin/env bash

./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make check || (cat tests/test-suite.log && echo "ERROR: make check failed, see above" && exit 1)
make install
