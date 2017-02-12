#!/bin/bash

export CPPFLAGS="-I$PREFIX/include -DDISABLE_COMMENTATOR $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -fPIC $CFLAGS"
export CXXFLAGS="-g -fPIC $CXXFLAGS"

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --with-default="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --enable-sage \
    --disable-openmp \
    --without-ocl \
    --without-fplll \
    --with-iml="$PREFIX" \
    --with-m4ri="$PREFIX" \
    --with-m4rie="$PREFIX" \
    --with-ntl="$PREFIX"

make -j${CPU_COUNT}
make check
make install
