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
	-DCMAKE_BUILD_TYPE=Release \
	-DREADOUT_BUILD_ON_CONDA=ON \
	-DREADOUT_BUILD_TESTS=OFF \
	-DREADOUT_USE_CONAN=OFF \
	-DHIGHFIVE_USE_INSTALL_DEPS=ON

cmake --build ./build --config Release -j

cmake --build ./build --target install

