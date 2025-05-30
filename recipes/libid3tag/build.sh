#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ${CMAKE_ARGS}
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build
