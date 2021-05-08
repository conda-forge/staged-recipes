#!/bin/bash
export CC=$(basename ${CC})
export FC=$(basename ${FC})
export F77=$(basename ${F77})
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"
if [[ $(uname) == Darwin ]]; then
    export PATH="${RECIPE_DIR}/fake-bin:$PATH"
    export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
    
fi

./waf configure --prefix=${PREFIX} --release-with-symbols
./waf build
./waf install
