#!/usr/bin/env bash

if [[ $PY3K == "1" ]]; then
    OPTIONS="--with-python=python3"
fi
./autogen.sh
./configure --prefix="$PREFIX" $OPTIONS
make -j${CPU_COUNT}
make install
