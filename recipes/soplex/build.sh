#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cmake -B build -S "${SRC_DIR}" -D CMAKE_BUILD_TYPE=Release -D BOOST=OFF -D BUILD_SHARED_LIBS=ON
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --prefix "${PREFIX}"
