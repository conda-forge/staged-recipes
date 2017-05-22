#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
    export ENABLE_OPENMP=no
    export LDFLAGS="${LDFLAGS} -Wl,-dead_strip_dylibs"
else
    export ENABLE_OPENMP=yes
    export LDFLAGS="${LDFLAGS} -Wl,--as-needed"
fi

mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DITK_DIR=$PREFIX/lib/cmake/ITK-4.11/ \
    -DIIBOOST_USE_OPENMP=$ENABLE_OPENMP \
	..

make

make install

# Testing.
if [[ $PY3K == 0 && "$(uname)" != "Darwin" ]]; then
    cd ../python/tests/
    python python_test_raw.py
fi
