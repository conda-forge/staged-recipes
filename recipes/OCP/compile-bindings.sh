#!/bin/sh

set -euo pipefail

# The CMake files bundled with OCP make reference the env var `CONDA_PREFIX`.
# That is the right prefix when manually running CMake instead a conda env, but
# the wrong one when using conda-build. Substitute the right prefix inline.
CONDA_PREFIX=${PREFIX} cmake -S ${PREFIX}/src/OCP/ -B build
cmake --build build -- -j${CPU_COUNT}

mkdir -p ${SP_DIR}
cp build/OCP.cp*-*.* ${SP_DIR}
