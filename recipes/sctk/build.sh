#!/bin/bash

set -euo pipefail

make config prefix=$PREFIX -j $CPU_COUNT 
make all prefix=$PREFIX -j $CPU_COUNT OPTIONS=-DNEED_STRCMP=0
mkdir -p $PREFIX/bin
make install prefix=$PREFIX -j $CPU_COUNT