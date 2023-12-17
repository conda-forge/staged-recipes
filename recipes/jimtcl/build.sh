#!/bin/sh

set -e

export MAKE="${MAKE:-make}"
./configure --prefix=$PREFIX "$@"
$MAKE

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    $MAKE install

    # we aren't shipping Jim as a library right now, due to shlib problems
    rm $PREFIX/lib/libjim.a
    rm $PREFIX/include/jim*.h
fi

