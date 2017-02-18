#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

# Build
make -j${CPU_COUNT} PREFIX=${PREFIX}
make -C tests datagen

# Test
LZ4=./lz4
DATAGEN=./tests/datagen

# This is a shorter version of `make lz4-test-basic`.
$DATAGEN -g0     | $LZ4 -v     | $LZ4 -t
$DATAGEN -g16KB  | $LZ4 -9     | $LZ4 -t
$DATAGEN         | $LZ4        | $LZ4 -t
$DATAGEN -g6M -P99 | $LZ4 -9BD | $LZ4 -t
$DATAGEN -g17M   | $LZ4 -9v    | $LZ4 -qt
$DATAGEN -g33M   | $LZ4 --no-frame-crc | $LZ4 -t
$DATAGEN -g256MB | $LZ4 -vqB4D | $LZ4 -t

# Install
make install PREFIX=${PREFIX}
