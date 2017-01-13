#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug
./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make install
make check
