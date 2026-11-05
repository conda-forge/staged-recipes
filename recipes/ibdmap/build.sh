#!/bin/bash
set -euxo pipefail

cmake ${CMAKE_ARGS} -G Ninja -DCMAKE_INSTALL_PREFIX=${PREFIX} -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
cmake --build build -j${CPU_COUNT}
cmake --install .
