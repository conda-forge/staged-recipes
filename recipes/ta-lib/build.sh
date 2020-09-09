#!/bin/bash
pushd lib
./configure --prefix=$PREFIX
make
make install
popd

pushd py
export LD_LIBRARY_PATH="${PREFIX}/lib"
export TA_INCLUDE_PATH="${PREFIX}/include"
export TA_LIBRARY_PATH="${PREFIX}/lib"

$PYTHON setup.py build
$PYTHON setup.py install --prefix=$PREFIX
