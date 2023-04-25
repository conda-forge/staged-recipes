#! /bin/bash

set -e
set -x

if [[ "${target_platform}" == "linux-64" ]]; then
    make CONFIG=gcc
else; then
    make CONFIG=clang
fi

make install
