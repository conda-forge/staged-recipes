#!/bin/bash

export CFLAGS="-I$PREFIX/include $CFLAGS"
export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I/$PREFIX/include $CPPFLAGS"

pushd gridgen

./configure --prefix=$PREFIX

make
make lib
make shlib
make tests
make install

popd
