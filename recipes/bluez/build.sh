#!/usr/bin/env bash

./configure --prefix=$PREFIX \
	--mandir=$PREFIX/share/man \
	--sysconfdir=$PREFIX/etc \
	--localstatedir=$PREFIX/var

make
make install
