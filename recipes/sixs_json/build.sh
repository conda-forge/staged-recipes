#!/bin/bash

export FFLAGS=$(echo "${FFLAGS}" | sed "s/-fopenmp//g")

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR

make -j${CPU_COUNT}
make install

$PYTHON -m pip install .
