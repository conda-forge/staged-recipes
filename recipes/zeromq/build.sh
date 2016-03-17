#!/bin/bash

# default is 10.5 for some reason, which doesn't work
if [[ `uname` == 'Darwin' ]];
then
    export MACOSX_DEPLOYMENT_TARGET=10.7
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

./autogen.sh
./configure \
	    --prefix="${PREFIX}" \
	    --with-libsodium="${PREFIX}" \
	    --without-documentation
make
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
make install
