#!/bin/bash


./configure --prefix=${PREFIX} --with-openssl --with-libz --with-libxml2 --with-libssh2 --with-libcares --with-sqlite3

make -j${CPU_COUNT}
make install
