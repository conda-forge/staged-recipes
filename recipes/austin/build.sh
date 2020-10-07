#!/bin/bash

if [[ "$target_platform" == "linux-64" ]]; then
    export CFLAGS="${CFLAGS} -lrt"
fi

autoreconf --install
./configure --prefix=${PREFIX}

make
make install

${PYTHON} -m pip install . -vv
