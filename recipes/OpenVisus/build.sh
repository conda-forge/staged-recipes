#!/bin/bash

# TODO for python2.x we probably have to add -DPYTHON_VERSION=2

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDISABLE_OPENMP=1 -DVISUS_GUI=0 -DVISUS_INTERNAL_DEFAULT=1 ..
cmake --build . --target all -- -j 4
cmake --build . --target install

cd install
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
