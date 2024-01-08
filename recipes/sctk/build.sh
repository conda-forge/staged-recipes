#!/bin/bash

set -euo pipefail

make config prefix=$PREFIX -j $CPU_COUNT LDFLAGS="-L$CONDA_PREFIX/lib" CPPFLAGS="-I$CONDA_PREFIX/include"
make all prefix=$PREFIX -j $CPU_COUNT OPTIONS=-DNEED_STRCMP=0
mkdir -p $PREFIX/bin
make install prefix=$PREFIX -j $CPU_COUNT
