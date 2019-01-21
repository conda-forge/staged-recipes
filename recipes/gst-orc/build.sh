#!/bin/bash

# conda-forge/conda-forge.github.io#621
find ${PREFIX} -name "*.la" -delete

# configure using PYTHON=pythonX.Y to get correct includes path
./configure \
	PYTHON=${PYTHON}${PY_VER} \
	--prefix=${PREFIX}

# make and install
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
