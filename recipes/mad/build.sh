#!/bin/bash

sed -i -- "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" configure.ac
touch NEWS AUTHORS ChangeLog
autoreconf -fi
./configure --prefix=${PREFIX} --disable-static
make install
