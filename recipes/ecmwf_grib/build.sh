#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

./configure --prefix=$PREFIX \
            --with-jasper=$PREFIX \
            --with-netcdf=$PREFIX \
            --with-png-support \
            --disable-fortran \
            --disable-python

make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
