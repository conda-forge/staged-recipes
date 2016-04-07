#!/usr/bin/env bash

# The without snapshot comes from the error in
# https://github.com/nodejs/node/issues/4212.
./configure --prefix=$PREFIX --without-snapshot
make
make install

