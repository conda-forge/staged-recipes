#!/bin/bash

cd src

autoreconf -i

./configure --prefix=$PREFIX

make
if [ "$PY_VER" == "2.7" ]; then
  make check
fi
make install
