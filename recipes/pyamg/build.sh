#!/bin/bash

# On OSX, we need to ensure we're using conda's gcc/g++
if [[ `uname` == Darwin ]]; then
    export CC=gcc
    export CXX=g++
fi

$PYTHON setup.py install
