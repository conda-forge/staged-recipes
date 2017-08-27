#!/bin/bash
if [[ `uname` == 'Darwin' ]];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ `uname` == 'Linux' ]];
then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi
./configure --prefix="${PREFIX}" --libdir="${PREFIX}/lib/" --with-lib-path="${PREFIX}/lib/"
make
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make install

