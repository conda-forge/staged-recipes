#!/bin/bash
if [[ $(uname) == Darwin ]]; then
    export PATH="${RECIPE_DIR}/fake-bin:$PATH"
    export FFLAGS="$FFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

./waf configure --prefix=${PREFIX} --release-with-symbols
./waf build
./waf install
