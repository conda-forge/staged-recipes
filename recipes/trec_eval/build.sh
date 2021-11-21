#!/bin/bash

set -ex

# compile
make -j$CPU_COUNT

# test
make quicktest

# install (cannot use 'make install')
mkdir -p $PREFIX/bin
cp ./trec_eval $PREFIX/bin/trec_eval
