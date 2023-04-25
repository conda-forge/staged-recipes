#! /bin/bash

set -e
set -x

if [[ "${target_platform}" == "linux-64" ]]; then
    # expects `gcc`
    ln -s $GCC $BUILD_PREFIX/bin/gcc

    # TODO this doesnt work
    # alias gcc=$CC

    make CONFIG=gcc
else
    make CONFIG=clang
fi

make install
