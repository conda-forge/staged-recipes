#!/bin/bash

set -ex

mkdir -pv build
pushd build

cmake \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DCMAKE_INSTALL_LIBDIR:PATH="lib" \
	-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
	${SRC_DIR}

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
