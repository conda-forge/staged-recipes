#!/usr/bin/env bash

# Required to avoid linking issue when running "make check" on macOS
export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib

./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make check || (cat tests/test-suite.log && echo "ERROR: make check failed, see above" && exit 1)
make install
