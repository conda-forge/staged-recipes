#!/bin/bash

cd $SRC_DIR/src

configure --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
