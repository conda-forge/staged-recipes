#!/usr/bin/env bash
set -e -x

cp -r mariadb-connector-c/. server-mariadb/libmariadb

cd server-mariadb
mkdir builds
cd builds

cmake ${CMAKE_ARGS} \
    -S .. \
    -B ./builds \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DBUILD_CONFIG=mysql_release \
    -DTOKUDB_OK=0 \
    -DPLUGIN_AUTH_PAM=NO


make -k -j${CPU_COUNT}
ctest --rerun-faild --output-on-failure
make install