#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

./autogen.sh

./configure --prefix="${PREFIX}" \
            --with-iconv="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-icu \
            --with-lzma="${PREFIX}" \
            --without-python
make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
