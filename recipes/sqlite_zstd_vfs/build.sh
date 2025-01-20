#!/bin/bash

set -ex

cmake $CMAKE_ARGS \
    -DCMAKE_BUILD_TYPE=Release \
    -B build \


sed -i.bak '1i #include <climits>' build/_deps/sqlite_web_vfs-src/src/SQLiteVFS.h

cmake --build build

mkdir -p $PREFIX/lib
find . -name *zstd_vfs$SHLIB_EXT* -exec ls -l {} \;
cp $(find . -name zstd_vfs$SHLIB_EXT | tail -n 1) $PREFIX/lib

# Simple test
echo '.quit' | sqlite3 -cmd ".load zstd_vfs"
