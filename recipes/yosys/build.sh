#! /bin/bash

set -e
set -x

if [[ "${target_platform}" == "linux-64" ]]; then
    alias gcc=`$CC`
    make CONFIG=gcc
else
    make CONFIG=clang
fi

make install
