#!/usr/bin/env bash
set -euxo pipefail

export CMAKE_GENERATOR=Ninja
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-2}"

echo "PYTHON=${PYTHON}"
echo "CC=${CC:-}"
echo "CXX=${CXX:-}"

which cmake
cmake --version
which ninja
ninja --version

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
