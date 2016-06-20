#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

# Needed for the tests.
export CFLAGS="-std=c99 ${CFLAGS}"

if [ "`uname`" == 'Darwin' ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi


aclocal
autoconf
autoreconf -ivf
./configure --prefix=${PREFIX} \
            --with-expat \
            --without-nettle \
            --without-lz4 \
            --without-lzmadec \
            --without-xml2
make
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
make install
