#!/usr/bin/env bash
set -e -x

# cp -r mariadb-connector-c/. server-mariadb/libmariadb

git clone https://github.com/codership/wsrep-lib.git server-mariadb/wsrep-lib
git clone https://github.com/mariadb-corporation/mariadb-connector-c.git server-mariadb/libmariadb


cd server-mariadb

# git clean -xffd
# git submodule foreach --recursive git clean -xffd

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DBUILD_CONFIG=mysql_release \
    -DTOKUDB_OK=0 \
    -DPLUGIN_AUTH_PAM=NO \
    ../.

make -k -j${CPU_COUNT}
ctest --rerun-faild --output-on-failure
make install