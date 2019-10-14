#!/usr/bin/env bash

export DYLD_LIBRARY_PATH=$PREFIX/lib

./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make check || (cat tests/test-suite.log && echo "ERROR: make check failed, see above" && exit 1)
make install
