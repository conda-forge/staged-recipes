#!/bin/bash

export USE_CYTHON=True

export CC=gcc CXX=g++

$PYTHON setup.py build_ext -I$PREFIX/include \
                 install --single-version-externally-managed --record record.txt
