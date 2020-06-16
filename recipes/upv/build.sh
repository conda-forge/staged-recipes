#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake ${SRC_DIR} \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DCMAKE_INSTALL_DATADIR:PATH=${SRC_DIR}/trash \
	-DCMAKE_INSTALL_LIBDIR:PATH="lib" \
	-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
