#!/bin/bash

set -xeuo pipefail

cmake -S. -B build -GNinja ${CMAKE_ARGS} -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build build -j${CPU_COUNT}
cmake --install build
