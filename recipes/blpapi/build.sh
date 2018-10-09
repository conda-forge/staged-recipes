#!/bin/bash

export BLPAPI_ROOT="."
$PYTHON setup.py install
cp -v $BLPAPI_ROOT/Linux/lib*.so $PREFIX/lib/
