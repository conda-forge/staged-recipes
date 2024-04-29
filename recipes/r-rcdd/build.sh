#!/bin/bash
export DISABLE_AUTOBREW=1

export CFLAGS="-I${CONDA_PREFIX}/include/ -RPATH ${BUILD_PREFIX}/lib/"

${R} CMD INSTALL --build . ${R_ARGS}
