#!/usr/bin/env bash
set -e -x

# Copy mariadb-connector-c to server
cp -R connector/. server/libmariadb

# Now move to server folder
cd server

# Git clone wsrep library
git clone https://github.com/codership/wsrep-lib.git wsrep-lib
cd wsrep-lib
git submodule update --init --recursive
cd ..

# Git clone wolfssl
git clone https://github.com/wolfSSL/wolfssl.git extra/wolfssl/wolfssl
cd extra/wolfssl/wolfssl
git submodule update --init --recursive
cd ../../..

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

# Git clone libmarias3
git clone https://github.com/mariadb-corporation/libmarias3.git storage/maria/libmarias3
cd storage/maria/libmarias3
git submodule update --init --recursive
cd ../../..

# Make build directory
mkdir building
cd building

# Build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=mysql_release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=OFF \
    -DCMAKE_SHARED_LIBS=ON \
    -DWITH_SAFEMALLOC=ON \
    -DBUILD_CONFIG=mysql_release \
    -DPLUGIN_AUTH_PAM=NO \
    -DPLUGIN_OQGRAPH=NO \
    -DPLUGIN_ROCKSDB=NO \
    -DMYSQL_MAINTAINER_MODE=OFF \
    -DAWS_SDK_EXTERNAL_PROJECT=OFF \
    ..

make -k -j${CPU_COUNT}

# Test
# ctest --rerun-failed --output-on-failure

# Build
cmake --build . --verbose