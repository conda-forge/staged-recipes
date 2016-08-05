#!/bin/bash

if [ $(uname) == Darwin ]; then
  export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
fi


$PYTHON setup.py install
