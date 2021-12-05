#!/bin/bash

set -x

pwd

./configure
make

pwd

mkdir -p $PREFIX/bin
cp src/sample $PREFIX/bin/sample
