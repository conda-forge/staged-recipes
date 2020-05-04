#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

autoconf
./configure --prefix="$PREFIX"
make -j$CPU_COUNT
make -j$CPU_COUNT test
make install
