#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cmake -B build -S scipoptsuite/scip/examples/Queens -D CMAKE_BUILD_TYPE=Release

cmake --build build --parallel ${CPU_COUNT}

./build/queens 5
scip --version
