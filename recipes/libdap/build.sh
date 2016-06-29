#!/bin/bash

export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"

autoreconf --force --install

bash configure \
    --enable-threads=pth \
	--with-xml2=$PREFIX \
	--with-curl=$PREFIX \
    --prefix=$PREFIX

make
make check
make install
