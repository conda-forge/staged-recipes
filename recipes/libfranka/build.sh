#!/bin/bash

set -exo pipefail

cmake -B build ${CMAKE_ARGS} -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF  $SRC_DIR -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build --config Release --target install
