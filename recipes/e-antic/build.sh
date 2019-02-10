#!/usr/bin/env bash

export CFLAGS="-O2 -g $CFLAGS"
export CXXFLAGS="-O2 -g $CXXFLAGS"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"

if [ "$(uname)" == "Darwin" ]; then
    CXXFLAGS="$CXXFLAGS -fno-common"
fi

./configure --prefix="$PREFIX"

make -j${CPU_COUNT}
make check
make install
