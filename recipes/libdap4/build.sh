#!/bin/bash

export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"

autoreconf --force --install

bash configure --prefix=$PREFIX \
               --enable-threads=pth \
               --with-xml2=$PREFIX \
               --with-curl=$PREFIX \


make
# make check fails on os x for some reason.
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  make check
fi
make install
