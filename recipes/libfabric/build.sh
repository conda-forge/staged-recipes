#!/bin/bash

set -ex

export CC=$(basename "$CC")

./autogen.sh

./configure --prefix=$PREFIX \
	    --with-numa=$PREFIX \
	    --with-libnl=$PREFIX

make -j"${CPU_COUNT}"
make install

