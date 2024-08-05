#!/bin/bash

set -ex

./autogen.sh
./configure --prefix=$CONDA_PREFIX
make -j $CPU_COUNT
make install
