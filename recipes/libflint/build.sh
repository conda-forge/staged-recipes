#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

chmod +x configure

# This is set to reduce the number of random tests run so that CIs can run 
# tests to completion without timeouts.
echo "int flint_test_multiplier(){return 1;}" > test_helpers.c

./configure --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX
make
make check
make install
