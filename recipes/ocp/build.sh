#!/bin/sh
set -euo pipefail

# FindOpenCascade.cmake bundled with OCP references the env var `CONDA_PREFIX`.
# That is the right prefix when manually running CMake instead a conda env, but
# the wrong one when using conda-build. Substitute the right prefix inline.
CONDA_PREFIX="${PREFIX}" cmake -B build -S "${SRC_DIR}" \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release

cmake --build build -j ${CPU_COUNT}

mkdir -p "${SP_DIR}"
cp build/OCP.cp*-*.* "${SP_DIR}"
