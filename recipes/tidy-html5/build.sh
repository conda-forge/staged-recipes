#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build_out ${CMAKE_ARGS}
cmake --build -j${CPU_COUNT} build_out
cmake --install build_out
