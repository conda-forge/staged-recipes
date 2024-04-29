#!/bin/bash
export DISABLE_AUTOBREW=1
export R="-L$PREFIX/lib/R/lib"
export CFLAGS="-I${CONDA_PREFIX}/include/"

${R} CMD INSTALL --build . ${R_ARGS}
