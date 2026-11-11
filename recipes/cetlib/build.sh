#!/bin/bash
# cetlib: core utility library for the art suite (plugin/library management,
# filesystem/search-path helpers, MD5/SHA1/CRC, SQLite helpers). Links boost,
# SQLite3, OpenSSL and cetlib_except. Same cetmodules build pattern as the rest.
set -euo pipefail

mkdir -p build
cd build

# CMAKE_PREFIX_PATH=$PREFIX so find_package() resolves cetmodules + cetlib_except
# (local art-suite channel) and Boost/SQLite3/OpenSSL (conda-forge) from the host
# env. BUILD_TESTING=OFF -> skip the test/ subdir (the only Catch2 user).
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

# Like cetmodules/cetlib_except, cetlib installs LICENSE/README as plain files at
# the PREFIX ROOT. $PREFIX/README (a file) collides with ROOT's $PREFIX/README/
# directory -- a file-vs-directory clash (ENOTDIR) when both land in one env at
# canvas_root_io (#7). Strip the stray prefix-root docs (license_file copies
# LICENSE from the SOURCE, so this does not affect it).
# See conda/potential_improvements.md (#7).
rm -f "$PREFIX/INSTALL" "$PREFIX/LICENSE" "$PREFIX/README"
