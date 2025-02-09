#!/usr/bin/env bash

# NOTICE: Keep synchronized with bld.bat

set -eux
mkdir -p build

test -f "${SRC_DIR}/lib/Readout.h"

cmake \
	-B ./build \
	-S "${SRC_DIR}" \
	${CMAKE_ARGS} \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_BUILD_TYPE=Release

cmake --build ./build --config Release --target readout_tester -j

cd ./build

ctest 



