#!/bin/bash
set -euxo pipefail

# ZXING_WRITERS=OLD uses the self-contained legacy writer backend instead of
# the new zint-based one, which lives in an un-vendored git submodule (zint/)
# that a source tarball does not include and network access is unavailable
# during the build. ZXING_C_API=OFF avoids the C wrapper's stb dependency,
# which is likewise only fetched over the network at configure time.
cmake -GNinja -B build ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DZXING_READERS=ON \
  -DZXING_WRITERS=OLD \
  -DZXING_C_API=OFF \
  -DZXING_EXPERIMENTAL_API=OFF \
  -DZXING_EXAMPLES=OFF \
  -DZXING_EXAMPLES_QT=OFF \
  -DZXING_BLACKBOX_TESTS=OFF \
  -DZXING_UNIT_TESTS=OFF

cmake --build build
cmake --install build
