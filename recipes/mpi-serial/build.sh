#!/bin/bash

set -xe

export AR="${AR} cruv"
export INSTALL="install"
export MKINSTALLDIRS="mkdir -p"
export libdir="${PREFIX}/lib"
export includedir="${PREFIX}/include"

./configure --prefix=${PREFIX}
make
make install
