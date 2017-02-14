#!/usr/bin/env bash

set -x -e

if [ "$(uname)" == "Darwin" ]; then
    cd macosx
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cd unix 
fi

./configure --prefix=$PREFIX
make
#make test
make install

