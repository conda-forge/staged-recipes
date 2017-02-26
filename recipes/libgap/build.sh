#!/bin/bash

source "$PREFIX/gap/latest/sysinfo.gap"

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"' -DSYS_DEFAULT_PATHS=\"'"$PREFIX/gap/latest"'\"'
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g -fPIC $CFLAGS"
export CXXFLAGS="-O2 -g -fPIC $CXXFLAGS"

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --with-gmp="$PREFIX" \
    --with-sage="$PREFIX" \
    --with-gap_system_arch="$GAParch_system"

make -j${CPU_COUNT}
make check
make install

