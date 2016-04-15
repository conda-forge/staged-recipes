#!/bin/bash

if [[ $(uname) == 'Darwin' ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == 'Linux' ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export CFLAGS="${CFLAGS} -pipe -O2 -fPIC -I${PREFIX}/include"

chmod +x configure

# The --enable-silent-rules is needed because Travis CI dies on the long output from this build.
./configure --prefix=${PREFIX}\
            --enable-linux-lfs \
            --enable-silent-rules \
            --with-ssl \
            --with-zlib \
            --with-jpeg \
            --disable-netcdf \
            --disable-fortran

make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install

# Remove man pages.
rm -rf ${PREFIX}/share

# People usually Google these.
rm -rf ${PREFIX}/examples
