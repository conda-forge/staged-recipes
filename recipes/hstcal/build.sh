#!/bin/bash
if [[ $target_platform == osx-* ]]; then
    export PATH="${RECIPE_DIR}/fake-bin:$PATH"
    export FFLAGS="$FFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

./waf configure --prefix=${PREFIX} --release-with-symbols
./waf build
./waf install
