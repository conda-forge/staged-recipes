#!/bin/bash

set -ex

# compile
make -j$CPU_COUNT

# test
make quicktest

# install (cannot use 'make install')
cp ./trec_eval $PREFIX/bin
