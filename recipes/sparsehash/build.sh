#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

# Setup the building
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

./configure --prefix=${PREFIX}
make
make check
make install
