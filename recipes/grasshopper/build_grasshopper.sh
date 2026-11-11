#!/bin/bash
set -euxo pipefail

# Core Geant4 only (no OpenGL/X11/Qt drivers): the VRML .wrl output grasshopper
# produces needs nothing beyond that, and it keeps the dependency set small.
# No ROOT: ASCII .dat output only.
cmake -S "${SRC_DIR}" -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DWITH_GEANT4_UIVIS=OFF \
  -DWITH_ROOT=OFF \
  -DBUILD_TESTING=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
