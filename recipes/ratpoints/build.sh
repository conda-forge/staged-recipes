#!/bin/bash

PRIME_SIZE=7
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CCFLAGS1="-I$PREFIX/include -Wall -O2 -fPIC -DRATPOINTS_MAX_BITS_IN_PRIME=$PRIME_SIZE $CFLAGS"
export CCFLAGS2=""
export CCFLAGS="-L$PREFIX/lib -lgmp -lm $LDFLAGS"
export INSTALL_DIR="$PREFIX"

make -e libratpoints.a
make -e test
make -e install-lib
