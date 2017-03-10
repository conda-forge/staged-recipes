#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"

# Build
make -j$CPU_COUNT

# Install
make install PREFIX=$PREFIX
