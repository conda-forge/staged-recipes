#!/bin/bash

mkdir -p build
pushd build

# configure
cmake ${SRC_DIR} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_LIBDIR="lib"

# build
cmake --build .

# test
ctest -VV

# install
cmake --build . --target install
