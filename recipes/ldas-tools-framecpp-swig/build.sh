#!/bin/bash

mkdir -p build
pushd build

# configure
cmake ${SRC_DIR} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_SWIG_PYTHON2=no \
	-DENABLE_SWIG_PYTHON3=no

# build
cmake --build . -- -j ${CPU_COUNT}

# test
ctest -VV

# install
cmake --build . --target install
