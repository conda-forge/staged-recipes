#!/bin/bash

# configure
mkdir -p _build
cd _build
cmake ${SRC_DIR} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DENABLE_BINARY_MATLAB=TRUE

# build
cmake --build . --parallel ${CPU_COUNT}

# check
ctest -V

# install
cmake --build . --target install
