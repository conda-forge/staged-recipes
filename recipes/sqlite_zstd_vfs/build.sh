#!/bin/bash

set -ex

# Update SQLiteCpp version
sed -i.bak 's,mlin/SQLiteCpp.git,SRombauts/SQLiteCpp,g' CMakeLists.txt
sed -i.bak 's,6d089fc,643b153,g' CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build

mkdir -p $PREFIX/lib
find . -name *zstd_vfs$SHLIB_EXT* -exec ls -l {} \;
cp $(find . -name zstd_vfs$SHLIB_EXT | tail -n 1) $PREFIX/lib

echo '.quit' | sqlite3 -cmd ".load zstd_vfs"
