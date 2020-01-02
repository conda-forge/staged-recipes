#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake ${SRC_DIR} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_INSTALL_DOCDIR:PATH=${SRC_DIR}/trash \
	-DCMAKE_INSTALL_LIBDIR:PATH="lib" \
	-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
;

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install
