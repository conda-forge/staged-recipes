#!/bin/bash
set -ex

./autogen.sh
./configure --prefix=$PREFIX
make -j $CPU_COUNT
make install
