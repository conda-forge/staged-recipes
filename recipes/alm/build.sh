#!/bin/bash

cd python

export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/include:$CONDA_PREFIX/include/eigen3
export LIBRARY_PATH=$CONDA_PREFIX/lib:${LIBRARY_PATH}
export CC=$CXX

$PYTHON setup.py install --single-version-externally-managed --record record.txt

ls -lR
