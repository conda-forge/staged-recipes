#!/bin/sh

cd ${SRC_DIR}/apr
./configure --prefix=${PREFIX} --host=${HOST}
make
make install

cd ${SRC_DIR}/apr-util
./configure --prefix=${PREFIX} --host=${HOST} --with-apr=${PREFIX}
make
make install

cd ${SRC_DIR}/apr-iconv
./configure --prefix=${PREFIX} --host=${HOST} --with-apr=${PREFIX}
make
make install
