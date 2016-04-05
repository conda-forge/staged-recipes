#!/bin/bash

if [[ $(uname) == 'Darwin' ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == 'Linux' ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

./autogen.sh

./configure --prefix="${PREFIX}" \
            --with-iconv="${PREFIX}" \
            --with-lzma="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-icu \
            --without-python
make

# Correct weirdly linked library paths.
if [[ $(uname) == 'Darwin' ]]; then
  LIBDIR="${PREFIX}/lib"
  LIBICUDATA="`cd ${LIBDIR} && ls libicudata.*.*.dylib`"
  find "${SRC_DIR}/.libs" -type f | xargs -I {} install_name_tool -change "../lib/${LIBICUDATA}" "${PREFIX}/lib/${LIBICUDATA}" {} || true
#   find "${SRC_DIR}/python/.libs" -type f | xargs -I {} install_name_tool -change "../lib/${LIBICUDATA}" "${PREFIX}/lib/${LIBICUDATA}" {} || true
fi
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
