#!/bin/bash
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

if [[ $(uname) == Darwin ]]; then
    export PATH="${RECIPE_DIR}/fake-bin:$PATH"
    export FFLAGS="$FFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

./waf configure --prefix=${PREFIX} --release-with-symbols
./waf build
./waf install
