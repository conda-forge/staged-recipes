#!/bin/bash
pushd ta-lib
./configure --prefix=$LIBRARY_PREFIX
make
make install
popd