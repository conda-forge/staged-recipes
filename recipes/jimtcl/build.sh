#!/bin/sh

set -e

./configure --prefix=$PREFIX "$@" --shared
${MAKE:-make}

if [[ "$JIM_CONDA_INSTALL" != no ]]; then
    ${MAKE:-make} install
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    ${MAKE:-make} check
fi