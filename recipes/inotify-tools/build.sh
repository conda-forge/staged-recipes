#!/usr/bin/env bash

./autogen.sh
./configure --prefix=$CONDA_PREFIX
make
make check
make install
