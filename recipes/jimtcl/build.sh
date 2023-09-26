#!/bin/sh

set -e

./configure --prefix=$PREFIX
make
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    make check
fi

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    make install
fi