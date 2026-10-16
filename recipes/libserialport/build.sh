#!/bin/sh
set -eu

cmake -S . -B build -G "Unix Makefiles" ${CMAKE_ARGS:-} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="-O2" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=ON
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
test_baud_termiox.sh
