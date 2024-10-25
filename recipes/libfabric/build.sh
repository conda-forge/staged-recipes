#!/bin/bash

set -ex

export CC=$(basename "$CC")

./configure --prefix=$PREFIX \
	    --with-numa=$PREFIX \
	    --with-libnl=$PREFIX

make -j"${CPU_COUNT}"
make check
make install

