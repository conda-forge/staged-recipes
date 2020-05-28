#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# configure
cmake \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
	${SRC_DIR} \
;

# build
cmake --build . --parallel ${CPU_COUNT}

# test
ctest -V

# install
cmake --build . --parallel ${CPU_COUNT} --target install
