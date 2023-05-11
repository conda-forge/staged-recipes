#!/bin/bash

export AR="${AR} cruv"
export INSTALL="install"

./configure --prefix=${PREFIX}
make
make install
