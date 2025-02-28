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
	-DREADOUT_BUILD_TESTS=ON \
	-DREADOUT_USE_CONAN=OFF \
	-DHIGHFIVE_USE_INSTALL_DEPS=ON

cmake --build ./build --config Release -j${CPU_COUNT}

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
	ctest --test-dir ./build --output-on-failure --build-config Release
fi

cmake --build ./build --target install

