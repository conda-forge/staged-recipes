#!/bin/bash

export AR="${AR} cruv"

./configure --prefix=${PREFIX}
make
make install
