#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

# Setup the boost building, this is fairly simple.
export CFLAGS="-O3"
export CXXFLAGS="-O3"

./configure --prefix=${PREFIX}
make
make check
make install
