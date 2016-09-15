#!/bin/bash

set -e

./configure --prefix=$PREFIX \
	    --with-zlib=$PREFIX \
	    --with-bzip=$PREFIX

make
if [[ $(uname) == Linux ]]; then
    make check
fi
make install
