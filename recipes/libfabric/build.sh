#!/bin/bash

set -ex

unset FC F77 F90

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")

./autogen.sh

./configure --prefix=$PREFIX \
	    --with-numa=$PREFIX \
	    --with-libnl=$PREFIX

make -j"${CPU_COUNT}"
make install

