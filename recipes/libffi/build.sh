#!/usr/bin/env bash

./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX}
make
make check
make install

if [[ $(uname) == Linux ]]; then
  mkdir -p ${PREFIX}/lib
  mv ${PREFIX}/lib64/* ${PREFIX}/lib/
fi
