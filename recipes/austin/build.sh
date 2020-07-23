#!/bin/bash

autoreconf --install
./configure --prefix=${PREFIX}
make
make install

${PYTHON} -m pip install . -vv
