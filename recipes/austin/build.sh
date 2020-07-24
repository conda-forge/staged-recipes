#!/bin/bash

if [[ $(uname) == "Linux" ]]; then
    export CFLAGS="${CFLAGS} -lrt"
fi

autoreconf --install
./configure --prefix=${PREFIX}
make
make install

${PYTHON} -m pip install . -vv
