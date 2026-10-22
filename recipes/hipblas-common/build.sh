#!/bin/bash
set -euxo pipefail

cmake ${CMAKE_ARGS} -G Ninja -S . -B build -DFETCHCONTENT_FULLY_DISCONNECTED=ON
cmake --build build
cmake --install build
