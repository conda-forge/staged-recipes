#!/usr/bin/env bash

set -euo pipefail

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS:-} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHIDAPITESTER_VERSION="v${PKG_VERSION}"

cmake --build build --config Release
cmake --install build --config Release
