#!/bin/bash
# canvas: the art suite's data-product/persistency model (the last pure-C++
# product before ROOT). Same cetmodules build pattern; find_package resolves
# the sibling closure + CLHEP/Range-v3/Boost from the host env.
set -euo pipefail

mkdir -p build
cd build

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
