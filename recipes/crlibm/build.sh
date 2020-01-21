#!/usr/bin/env bash

cd $SRC_DIR
./prepare
./configure --prefix=$PREFIX
make
make check
make install
