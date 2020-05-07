#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

autoconf
./configure --prefix="$PREFIX"
make -j$CPU_COUNT

if [[ "$(uname)" == "Darwin" ]]; then
    # static linking strategy of make_protect_lib example
    # doesn't work with clang on osx-64. End up with 
    #   ld: library not found for -lcrt0.o
    rm -rf examples/make_protect_lib
fi

make -j$CPU_COUNT test
make install
