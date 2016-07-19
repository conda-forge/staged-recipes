#!/usr/bin/env bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

# Setup the building
./configure --prefix=${PREFIX} \
            --enable-static=yes \
            --enable-shared=yes \
|| { cat config.log; exit 1; }

make
make check
make install
