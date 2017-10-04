#!/bin/bash

# fail on first error
set -e

cd $SRC_DIR
mkdir build && cd build
cmake ..
make
# make test
make install
