#!/bin/bash
export DISABLE_AUTOBREW=1

export CPFLAGS="-I${CONDA_PREFIX}/include/ ${CONDA_PREFIX}/include/"
export CFLAGS="-I${CONDA_PREFIX}/include/"
export CXXFLAGS="-I${CONDA_PREFIX}/include/"


${R} CMD INSTALL --build . ${R_ARGS}
