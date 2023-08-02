#!/usr/bin/env bash
set -e -x

# Copy mariadb-connector-c to server
cp -R ./connector/ ./server/libmariadb/

# Now move to server folder
cd ./server/

# Make build directory
mkdir build
cd build

# Build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc' \
    -DWITH_SAFEMALLOC=OFF \
    -DBUILD_CONFIG=mysql_release \
    ../server

make -k -j${CPU_COUNT}

# Test
cmake --build . --target test

# Build
cmake --build . --verbose