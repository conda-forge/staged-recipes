#!/usr/bin/env bash

set -e -o pipefail

./configure --prefix=$PREFIX --with-mem-dir=/dev/shm

make -j $CPU_COUNT
make install
