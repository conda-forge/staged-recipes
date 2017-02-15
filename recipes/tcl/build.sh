#!/usr/bin/env bash

set -x -e

if [ "$(uname)" == "Darwin" ]; then
    export INSTALL_ROOT=${PREFIX}
    cd macosx
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cd unix 
fi


./configure --prefix=$PREFIX
make prefix=$PREFIX
make prefix=$PREFIX install 
