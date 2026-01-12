#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S . -B build -G Ninja -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release ${CMAKE_ARGS}
cmake --build build
ctest --test-dir build --output-on-failure
cmake --install build
