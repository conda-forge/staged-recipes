#!/bin/sh

set -e

export MAKE="${MAKE:-make}"
./configure --prefix=$PREFIX "$@"
$MAKE

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    $MAKE install
fi
# we don't want to ship libraries, just the interpreter
rm -rf "$PREFIX/lib" "$PREFIX/include"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    $MAKE check
fi