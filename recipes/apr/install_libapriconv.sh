#!/bin/sh

cd "${SRC_DIR}/apr-iconv"
./configure --prefix="${PREFIX}" --host="${HOST}" --with-apr="${PREFIX}"
make
make install
