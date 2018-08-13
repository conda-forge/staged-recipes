#!/bin/bash

set -e

./configure --prefix=$PREFIX

make
make check &> make_check.log || { cat make_check.log; exit 1; }
make install
