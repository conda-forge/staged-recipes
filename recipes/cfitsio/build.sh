#! /bin/bash

set -e

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make stand_alone utils

# test-ish programs:
./cookbook
./speed
./testprog

make install

# NOTE: don't remove .a files! That's all we provide!
