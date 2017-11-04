#!/bin/bash

set -e
set -x

pushd src/c

./configure --with-pic --prefix=$PREFIX

make -j${CPU_COUNT}
make install
