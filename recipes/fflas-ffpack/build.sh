#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g $CFLAGS"
export CXXFLAGS="-g $CXXFLAGS"

chmod +x configure
./configure \
    --prefix="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --with-default="$PREFIX" \
    --with-blas-libs="-lopenblas" \
    --enable-optimization \
    --disable-simd \
    --enable-precompilation \
    --disable-openmp

make -j${CPU_COUNT}

if [ "$(uname)" != "Darwin" ]
then
    # appleclang crashes when following is run
    make check -j${CPU_COUNT}
fi
make install
