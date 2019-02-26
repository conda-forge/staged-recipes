#!/bin/sh

cd "${SRC_DIR}/apr-util"
./configure --prefix="${PREFIX}" --host="${HOST}" --with-apr="${PREFIX}" \
            --with-apr-iconv="./apr-iconv" --without-iconv --without-sqlite3
make
make install
