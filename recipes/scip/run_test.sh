#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Because we vendor Bliss only the license must be included
test $(find "$PREFIX" -iname '*bliss*' | grep -v 'info/license' | wc -l) -eq 0

cmake -B build -S scip/examples/Queens -D CMAKE_BUILD_TYPE=Release

cmake --build build --parallel ${CPU_COUNT}

./build/queens 5
scip --version
