#!/usr/bin/env bash

set -x -e

#if [ "$(uname)" == "Darwin" ]; then
#    cd macosx
#fi

./configure --prefix=$PREFIX
make
make test
make install

