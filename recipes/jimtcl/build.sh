#!/bin/sh

set -e

export MAKE="${MAKE:-make}"
./configure --prefix=$PREFIX "$@"
$MAKE

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    $MAKE install
fi

# we aren't shipping Jim in library-supporting mode right now
rm $PREFIX/libjim.a
rm $PREFIX/include/jim*.h

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    $MAKE check
fi