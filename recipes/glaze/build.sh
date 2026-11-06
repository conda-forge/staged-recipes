#!/bin/bash
set -euxo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DBUILD_TESTING=OFF \
  -Dglaze_ENABLE_FUZZING=OFF \
  -Dglaze_DEVELOPER_MODE=OFF
cmake --build build -j ${CPU_COUNT}
cmake --install build