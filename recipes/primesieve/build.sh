#!/bin/bash

if [[ `uname` == 'Darwin' ]];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

./configure --prefix="${PREFIX}"
make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
