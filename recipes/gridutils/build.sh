#!/bin/bash

export CFLAGS="-I$PREFIX/include $CFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CPPFLAGS="-I/$PREFIX/include $CPPFLAGS"

pushd gridutils

./configure --prefix=$PREFIX

make
pushd test
make
popd
make install

popd
