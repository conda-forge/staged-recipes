#!/bin/bash
set -ex

./configure --prefix=$PREFIX

make -j${CPU_COUNT} VERBOSE=1
make check
make install
