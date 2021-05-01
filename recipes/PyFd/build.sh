#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake ${SRC_DIR} \
        ${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_INSTALL_DATADIR:PATH=${SRC_DIR}/trash \
	-DCMAKE_INSTALL_LIBDIR:PATH="lib" \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
       -DPython3_EXECUTABLE:FILE=${PYTHON} \
;

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

#test
ctest
