#!/bin/sh

cd "${SRC_DIR}/apr"
./configure --prefix="${PREFIX}" --host="${HOST}"
make
make install
