#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# d-SEAMS
mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make install
ctest

# Luarocks
# $PREFIX/bin/luarocks-admin make_manifest --local-tree
# $PREFIX/bin/luarocks install luafilesystem --local-tree
# $PREFIX/bin/luarocks-admin make_manifest --local-tree
# sudo luarocks install luafilesystem
