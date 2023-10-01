#!/bin/sh

set -e

./configure --prefix=$PREFIX "$@"
${MAKE:-make}

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    ${MAKE:-make} install
fi
# we don't want to ship libraries, just the interpreter
rm -rf "$PREFIX/lib" "$PREFIX/include"

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    ${MAKE:-make} check
fi