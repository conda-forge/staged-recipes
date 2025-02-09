#!/usr/bin/env bash

# NOTICE: Keep synchronized with bld.bat

set -eux
mkdir -p build

test -f "${SRC_DIR}/lib/Readout.h"

cmake \
	-B ./build \
	-S "${SRC_DIR}" \
	${CMAKE_ARGS} \
	-GNinja \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_BUILD_TYPE=Release

cmake --build ./build --config Release -j

cmake --build ./build --target install

cd ./build

ctest 

