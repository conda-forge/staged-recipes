#!/usr/bin/env bash
set -e -x

# Copy mariadb-connector-c to server
cp -R connector/. server/libmariadb

# Git clone wsrep library
git clone https://github.com/codership/wsrep-lib.git server/wsrep-lib

# Now move to server folder
cd server

# Get submodules of wsrep
cd wsrep-lib
git submodule update --init --recursive
cd ..

# Git clone wolfssl
git clone https://github.com/wolfSSL/wolfssl.git extra/wolfssl
cd extra/wolfssl
git submodule update --init --recursive
cd ../..

# Git clone columnstore
git clone https://github.com/mariadb-corporation/mariadb-columnstore-engine.git storage/columnstore/columnstore
cd storage/columnstore/columnstore
git submodule update --init --recursive
cd ../../..

# Git clone rocksdb
git clone https://github.com/facebook/rocksdb.git storage/rocksdb/rocksdb
cd storage/rocksdb/rocksdb
git submodule update --init --recursive
cd ../../..

# Make build directory
mkdir building
cd building

# Build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-ltcmalloc" \
    -DWITH_SAFEMALLOC=OFF \
    -DBUILD_CONFIG=mysql_release \
    -DPLUGIN_AUTH_PAM=NO \
    -DPLUGIN_OQGRAPH=NO \
    ..

make -k -j${CPU_COUNT}

# Test
cmake --build . --target test

# Build
cmake --build . --verbose