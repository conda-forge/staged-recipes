#!/bin/bash

if [[ $(uname) == "Linux" ]]; then
    export CFLAGS="${CFLAGS} -lrt"
fi

autoreconf --install
./configure --prefix=${PREFIX}

[[ "$target_platform" == "win-64" ]] && patch_libtool

make
make install

${PYTHON} -m pip install . -vv
