#!/bin/bash
# hep_concurrency: cetmodules-based C++ library (SerialTaskQueue, WaitingTask,
# thread-safe utilities) built on TBB. Same build pattern as cetlib_except.
set -euo pipefail

mkdir -p build
cd build

# CMAKE_PREFIX_PATH=$PREFIX so find_package(cetmodules), find_package(cetlib_except)
# (local art-suite channel) and find_package(TBB) (conda-forge tbb-devel) resolve
# against the host env. BUILD_TESTING=OFF -> the test/ subdir (the only Catch2
# user) is skipped, so no catch2 is needed at configure time here.
# CMAKE_CXX_STANDARD=20: the e28 stack is C++20 (headers use concept/requires).
cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DBUILD_TESTING=OFF \
  -DWANT_UPS:BOOL=OFF \
  "$SRC_DIR"

make -j"${CPU_COUNT:-1}" install

# Strip stray prefix-root docs: $PREFIX/README (file) collides with ROOT's
# $PREFIX/README/ directory at canvas_root_io (#7) -- ENOTDIR / EPERM at host_env
# link/package time. (license_file: copies LICENSE from the SOURCE, not from here.)
# See conda/potential_improvements.md (#7) and the check-prefix-collisions skill.
rm -f "$PREFIX/INSTALL" "$PREFIX/LICENSE" "$PREFIX/README"
