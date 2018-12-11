#!/bin/bash

mkdir -p build
pushd build

cmake .. \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_SWIG_PYTHON2=no \
	-DENABLE_SWIG_PYTHON3=no
cmake --build . -- -j ${CPU_COUNT}
ctest -VV
