#!/bin/bash

cd python

export CPLUS_INCLUDE_PATH=$PREFIX/include:$PREFIX/include/eigen3:${CPLUS_INCLUDE_PATH}
export LIBRARY_PATH=$PREFIX/lib:${LIBRARY_PATH}
export CC=$CXX
export LDFLAGS="-fopenmp -lblas"

$PYTHON setup.py install --single-version-externally-managed --record record.txt

