#!/bin/bash
set -ex

mkdir -p build
cd build

# SPRING_NASM_EXECUTABLE: upstream otherwise prefers the prebuilt nasm binaries
# vendored in tools/host over the one on PATH.
# OpenMP_ROOT: keep FindOpenMP on the conda prefix instead of Homebrew's libomp.
cmake ${CMAKE_ARGS} \
	-DSPRING_ENABLE_COMPILER_CACHE=OFF \
	-DSPRING_NASM_EXECUTABLE="${BUILD_PREFIX}/bin/nasm" \
	-DOpenMP_ROOT="${PREFIX}" \
	"${SRC_DIR}" || (cat CMakeFiles/CMakeConfigureLog.yaml && exit 1)

make -j"${CPU_COUNT}"
make install
