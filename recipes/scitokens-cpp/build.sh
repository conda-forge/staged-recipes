#!/bin/bash

mkdir _build
pushd _build

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DBUILD_UNITTESTS:BOOL=TRUE \
;

# build
cmake --build . --verbose --parallel ${CPU_COUNT}

# test
ctest -V

# install
cmake --build . --verbose --parallel ${CPU_COUNT} --target install
