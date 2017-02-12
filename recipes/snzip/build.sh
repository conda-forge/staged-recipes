#!/bin/bash
set -ex

# Set paths for snappy headers and library.
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix=${PREFIX} --with-snappy=${PREFIX}/include

make -j${CPU_COUNT}
make check
make install
