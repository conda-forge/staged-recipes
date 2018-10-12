#!/bin/bash

export BLPAPI_ROOT="."
$PYTHON setup.py install

if [ -d "$BLPAPI_ROOT/Linux" ]; then
   cp -v $BLPAPI_ROOT/Linux/lib*.so $PREFIX/lib/
else
   cp -v $BLPAPI_ROOT/Darwin/lib*.so $PREFIX/lib/
fi
