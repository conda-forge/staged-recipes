#!/bin/bash

set -xeuo pipefail

./autogen.sh
./configure --prefix="${PREFIX}" --with-ucx="${PREFIX}" --with-cuda="${PREFIX}"
make -j $CPU_COUNT
make install

# Static libraries need to be shipped separately as per https://github.com/conda-forge/cfep/blob/main/cfep-18.md
# Deleting static libraries
find $PREFIX/lib -type f -name "*.a" -exec rm -f {} +
