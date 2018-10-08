#!/bin/bash

export BLPAPI_ROOT="blpapi_cpp_linux"
$PYTHON setup.py install
cp -v $BLPAPI_ROOT/Linux/lib*.so $PREFIX/lib/
