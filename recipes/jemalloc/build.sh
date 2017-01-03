#!/bin/bash

set -e
set -x

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make install
